
require_relative "../../app/services/hn_collect"

require 'webrick'
require 'webrick/https'
require 'tempfile'

class TestWebServer

  attr_reader :pid, :cert_name, :logger

  def initialize
    @cert_name = [ %w[CN localhost] ]
    @logger = WEBrick::Log.new(File.join(File.expand_path("~/tmp"), "hntophits-web-server-testing"))

    @pid = fork
    if not @pid # child
      Process::setsid
      Dir.chdir '/'
      $stdin.close
      $stdout.reopen('/dev/null', 'w+')
      $stderr.reopen('/dev/null', 'w+')
      server = WEBrick::HTTPServer.new(
        Port: 8080, SSLEnable: true, SSLCertName: @cert_name,
        Logger: @logger)

      setup_mounts server
      Signal.trap('TERM') { server.shutdown }
      server.start
      exit!
    end
    Signal.trap 'SIGCHLD', 'IGNORE'
    give_web_server_time_to_start
  end

  def stop
    if process_is_still_running
      kill_the_process
      while process_is_still_running
        wait_for_a_bit
      end
    end
  end

  def kill_the_process
    Process.kill('TERM', @pid)
  end

  def wait_for_a_bit
    Kernel.sleep 0.6
  end

  def process_is_still_running
    Process.kill(0, @pid)
    return true
  rescue Errno::ESRCH, Errno::EPERM, RangeError
    return false
  end

  def give_web_server_time_to_start
    Kernel.sleep 2
  end
end

class GoodTopStoriesServer < TestWebServer
  def setup_mounts server
    server.mount_proc '/v0/topstories.json' do |req, res|
      res['Content-Type'] = 'text/plain'
      res.body = '[123123123, 123123123]'
      res.status = 200
      res
    end
  end
end

class BadJSONServer < TestWebServer
  def setup_mounts server
    server.mount_proc '/v0/topstories.json' do |req, res|
      res['Content-Type'] = 'text/plain'
      res.body = '[badjson, 123123]'
      res.status = 200
      res
    end
  end
end

class ReadTimeoutServer < TestWebServer
  def setup_mounts server
    server.mount_proc '/v0/topstories.json' do |req, res|
      Kernel.sleep 8
      res['Content-Type'] = 'text/plain'
      res.body = '[badjson, 123123]'
      res.status = 200
      res
    end
  end
end

describe HNCollect do
  context "check the caching" do
    it "should not find the story cached" do
      expect(HNCollect.story_cached?(10)).to eq false
    end
    it "should find the story cached" do
      HNCollect.update_cache(121, "testing", "no ref")
      expect(HNCollect.story_cached?(121)).to eq true
    end
    it "should have consistent cache contents" do
      HNCollect.update_cache(121, "testing", "no ref")
      hn_id, description, href = HNCollect.last_top_story
      expect(hn_id).to eq 121
      expect(description).to eq "testing"
      expect(href).to eq "no ref"
    end
  end

  context "get_top_hit_details" do
    it "should find the story cached and call last_top_story" do
      top_hit = 121
      HNCollect.update_cache(top_hit, "testing", "no ref")
      expect(HNCollect).to receive(:last_top_story)
      HNCollect.get_top_hit_details(top_hit)
    end
    it "shouldn't find the story cached and call get_story" do
      top_hit = 121
      HNCollect.update_cache(10, "testing", "no ref")
      expect(HNCollect).to receive(:get_story).with(top_hit)
      HNCollect.get_top_hit_details(top_hit)
    end
    it "should exercise the return value of last_top_story" do
      top_hit = 121
      description = 'foobar'
      href = 'http://www.blah.com.au'
      HNCollect.update_cache(top_hit, description, href)
      rhn_id, rdescription, rhref = HNCollect.get_top_hit_details(top_hit)
      expect(rhn_id).to eq top_hit
      expect(rdescription).to eq description
      expect(rhref).to eq href
    end
  end

  context "adjusted_delay" do
    it "should return 0 if time taken is longer than 60 seconds" do
      expect(HNCollect.adjusted_delay(100, 200)).to eq 0
    end
    it "should cope with endtime being before starttime" do
      expect(HNCollect.adjusted_delay(200, 100)).to eq 0
    end
    it "should return a number less than 60 seconds" do
      expect(HNCollect.adjusted_delay(100, 103)).to eq 57
    end
  end

  RSpec.shared_context "connecting to test webserver" do
    let(:server) { nil }
    before :context do
      HNCollect.HackerNewsURL = 'localhost'
      HNCollect.HackerNewsPort = '8080'
    end
    after :example do
      @server.stop if @server
    end
  end

  describe "various results from connecting and querying a webserver" do

    describe "successful call to top stories" do
      include_context "connecting to test webserver"
      before :example do
        @server = GoodTopStoriesServer.new
      end
      it "will query server and find a hacker news id for the current top hit" do
        expect(HNCollect.get_top_hit).to eq 123123123
      end
    end

    describe "bad JSON" do
      include_context "connecting to test webserver"
      before :example do
        @server = BadJSONServer.new
      end
      it "will raise an exception indicating a problem with the JSON" do
        expect { HNCollect.get_top_hit }.to raise_error(JSON::ParserError)
      end
    end

    describe "what happens when the hacker news server isn't responding?" do
      # notice that a web server has not been started.
      it "will raise an exception because the webserver isn't running" do
        expect { HNCollect.https_get 'nonexistent' }.to raise_error(Errno::ECONNREFUSED)
      end
    end

    describe "read timeout to webserver" do
      include_context "connecting to test webserver"
      before :example do
        @server = ReadTimeoutServer.new
        HNCollect.ReadTimeOut = 5
      end
      it "will raise an exception indicating a problem with the JSON" do
        expect { HNCollect.get_top_hit }.to raise_error(Net::ReadTimeout)
      end
    end

  end

  describe "removing the reliance on collect.sh to restart the collection of data from hacker news" do
    it "will exercise the situation where an unexpected exception is thrown" do
      expect(HNCollect).to receive(:at_the_beginning_of_the_next_minute) { raise StandardError }
      expect(HNCollect).to receive(:log_error).with(/HNCollect.run: unexpected exception/)
      # since it's not possible to stub out retry
      expect(Kernel).to receive(:sleep).with(14) { raise }
      expect { HNCollect.run }.to raise_error(StandardError)
    end
  end

  context "trigger Net::ReadTimeout exception" do
    it "will exercise the Net::ReadTimeout exception and check for proper handling" do
      expect(HNCollect).to receive(:get_top_hit_stories) { raise Net::ReadTimeout }
      expect(HNCollect).to receive(:log_error).with(/Network Time out/)
      HNCollect.load_data_from_hackernews
    end
  end

  context "trigger Errno::ECONNREFUSED exception" do
    it "will exercise the Errno::ECONNREFUSED exception and check for proper handling" do
      expect(HNCollect).to receive(:get_top_hit_stories) { raise Errno::ECONNREFUSED }
      expect(HNCollect).to receive(:log_error).with(/connection refused/)
      HNCollect.load_data_from_hackernews
    end
  end

  context "trigger JSON::ParserError exception" do
    it "will exercise the JSON::ParserError exception and check for proper handling" do
      expect(HNCollect).to receive(:get_top_hit_stories) { raise JSON::ParserError }
      expect(HNCollect).to receive(:log_error).with(/bad JSON data returned/)
      HNCollect.load_data_from_hackernews
    end
  end

  context "trigger HNCollect::ServerUnavaiable exception" do
    it "will exercise the HNCollect::ServerUnavailable exception and check for proper handling" do
      expect(HNCollect).to receive(:get_top_hit_stories) { raise HNCollect::ServerUnavailable }
      expect(HNCollect).to receive(:log_error).with(/server unavailable/)
      expect(Kernel).to receive(:sleep).with(5) { raise StandardError }
      expect { HNCollect.load_data_from_hackernews }.to raise_error(StandardError)
    end
  end

end
