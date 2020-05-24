
require 'nokogiri'

module LoadDB

  class ElementNotFound < RuntimeError; end
  class BadHNId < RuntimeError; end
  class NothingToRead < RuntimeError; end
  class InvalidFileName < RuntimeError; end

  # Given a directory name, return an Enumerator that will return each
  # file to be processes in time order (oldest first).
  def self.files(dir)
    Dir.glob("#{dir}/news.*.gz").map {|f| File.basename(f).split('.')[1] }.sort {|a, b| a <=> b}.map {|f| "#{dir}/news.#{f}.gz" }
  end

  def self.valid_hn_id(elem)
    String(elem) =~ /^\d+$/ ? true : false
  end

  # If the filename starts with 'news.' and next has a valid date 'YYMMDDMMMM'
  def self.valid_name filename
    filename = File.basename(filename)
    fields = filename.split(/\./)
    raise InvalidFileName unless (fields.length == 2 or fields.length == 3)
    if filename =~ /^news\./ && fields[1] =~ /^\d{10}$/
      true
    else
      raise InvalidFileName
    end
  end

  # Get the date that the file was created from the file name.
  # Parse the date of the file and return it a string 'YYMMDDMMMM'
  # Up to the user to run valid_name on the filename first.
  def self.parse_date filename
    File.basename(filename).split(/\./)[1]
  end

  # If the filename ends with '.gz' open the file via gzip otherwise simply open the file.
  def self.openfile filename
    io = open(filename)
    if filename =~ /\.gz$/
      io = IO.popen("gunzip < #{filename} 2>/dev/null")
    end
    if block_given?
      begin
        yield io
      ensure
        io.close
      end
    else
      io
    end
  end

  # Make time
  #
  # The date used by the script to wget the contents of the hacker news site, is
  # YYMMDDmmss, which needs to be massaged into a format suitable for calling
  # Time.new
  # Return the a Time.new object made from the date.
  #
  def self.make_time(date)
    year, month, date, hour, minute, second = *date.scan(/../), 0
    Time.new(2000 + year.to_i, month, date, hour, minute, second)
  end

  def self.update_db(hn_id, date, href, description)
    story = OpenStruct.new(hn_id: hn_id, href: href, description: description)
    HackerNews.process_latest_hn_num_one(story: story, date: Time.now)
  end

  # :nodoc:
  # Comment on the long logic expression by method name rather than a comment.
  def self.element_has_one_child_and_href_begins_with_http elem
    elem.children && elem.children.length == 1 && elem['href'] && elem['href'] =~ /^http/
  end

  def self.open_and_read_file(filename)
    lines = []
    raise InvalidFileName unless valid_name(filename)
    openfile(filename) do |io|
      lines = io.readlines.join
    end
    if lines.empty? # gunzip failed / nothing to process
      raise NothingToRead, "file '#{filename}' contained no data"
    else
      yield lines
    end
  end

  def self.process_html_from_hacker_news(lines)
    elem = Nokogiri::HTML(lines).css('tr > td.title > a').find do |elem|
      element_has_one_child_and_href_begins_with_http elem
    end
    raise ElementNotFound unless elem
    begin # the evils of using exceptions for flow control.
      id_elem = elem.parent.parent.children[1].child.child['id'].sub('up_', '')
    rescue NoMethodError
      hacker_news_id_line = Nokogiri::HTML(lines).css('td > center > a')
      id_elem = hacker_news_id_line.first.attributes['id'].value.sub('up_', '')
      hacker_news_desc_line = Nokogiri::HTML(lines).css('td.title')
      elem = hacker_news_desc_line[1].children.find do |child|
        child.name == 'a'
      end
    end
    raise BadHNId unless valid_hn_id(id_elem)
    return id_elem, elem['href'], elem.children[0].content
  end

  def self.check_state_of_hacker_news_file(fullpath)
    open_and_read_file(fullpath) do |lines|
      id_elem, href, desc = process_html_from_hacker_news(lines)
    end
  end

  def self.make_processed_filename(dirname, basename)
    File.join(dirname, 'O'+basename)
  end

  def self.mark_file_as_processed(filename)
    basename, dirname = File.basename(filename), File.dirname(filename)
    FileUtils.move(filename, make_processed_filename(dirname, basename))
  end

  # Load the html from https://news.ycombinator.com, parse it and update the database.
  def self.load(dir)
    files(dir).each do |filename|
      begin
        date = parse_date(filename)
        open_and_read_file(filename) do |lines|
          puts "processing #{filename}"
          id_elem, href, desc = process_html_from_hacker_news(lines)
          update_db(id_elem, date, href, desc)
          mark_file_as_processed(filename)
        end
      rescue NoMethodError => e
        warn "Bad html tree in filename #{filename}"
      rescue Errno::ENOENT => e
        warn "Missing filename #{filename}: #{e.message}"
      rescue ElementNotFound => e
        warn "Bad HTML in file #{filename}: #{e.message}"
      rescue BadHNId => e
        warn "Bad Hacker News ID found in file #{filename}: #{e.message}"
      rescue NothingToRead => e
        warn "Empty input for file #{filename}: #{e.message}"
      rescue InvalidFileName => e
        warn "Bad file name for file #{filename}: #{e.message}"
      end
    end
  end

end
