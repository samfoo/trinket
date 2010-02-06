require 'lib/badges'

class EventsController < ApplicationController
  before_filter :require_user_or_error

  def create
    event = Event.create!(:name => params["name"],
                          :value => params["value"],
                          :email => params["email"]
                         )
    Trinket::Badges.award(event.user)

    respond_to do |format|
      format.json { render(:nothing => true) }
    end
  end
end