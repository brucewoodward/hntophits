class StoriesController < ApplicationController

  def index
    @stories = Story.by_most_time.page(params[:page])
  end

  def show
    @story = Story.find(params[:id])
  end

end
