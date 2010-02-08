class BadgesController < ApplicationController
  def index
    # TODO: Pagination 
  end

  def show
    @badge = Badge.find(params[:id])
  end
end
