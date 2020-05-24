class AlmostStoriesController < ApplicationController

  def index
    @stories = AlmostStory.by_time_created.page(params[:page])
  end

end
