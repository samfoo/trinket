# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f841aa65b094644ee7222b336bb72015'

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user_or_error
      unless current_user
        respond_to do |format|
          format.json { head :unauthorized }
        end

        return false
      end
    end
 
    def require_no_user_or_error
      if current_user
        respond_to do |format|
          format.json { head :unauthorized }
        end

        return false
      end
    end
end
