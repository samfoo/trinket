class BadgesController < ApplicationController
  def index
    @badges = Badge.find(:all)
  end

  def show
    @badge = Badge.find(params[:id])
  end
end
