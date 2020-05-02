class SearchStoriesController < ApplicationController

  def index
    @search_string = params.require(:search_string)
    @order_column_name = params.require(:order_column_name)
    @order_direction = params.require(:order_direction)
    @search_story = SearchStoryForm.new(search_string: @search_string, order_column_name: @order_column_name, order_direction: @order_direction)
    sanitise_search_string
    @stories = @search_story.fulfill
  end

  private

  def sanitise_search_string
    @search_string.gsub!(/[^[[:alnum:]]]/,'')
  end

end
