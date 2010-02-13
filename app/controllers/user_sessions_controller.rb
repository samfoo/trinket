class UserSessionsController < ApplicationController
  def new
    return redirect_to(user_url(:id => current_user.id)) if current_user

    @user = User.new
  end

  def create
    session = UserSession.new(params[:user])
    if session.save
      flash[:notice] = "Logged in successfully"
      redirect_to(user_url(:id => current_user.id)) 
    else
      flash[:error] = "Invalid email/password combination"
      redirect_to login_url 
    end
  end

  def destroy
    return redirect_to('/') unless current_user

    UserSession.find.destroy

    redirect_to('/')
  end
end
