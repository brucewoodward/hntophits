class TopHitsController < ApplicationController

  def index
    @top_hits = TopHit.recent_top_hits.page(params[:page])
  end

end
