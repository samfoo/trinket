class UsersController < ApplicationController
  def new
    return redirect_to(user_url(:id => current_user.id)) if current_user

    @user = User.new
  end

  def show
    @user = User.find(params[:id]) 
  end

  def create
    return redirect_to(user_url(:id => current_user.id)) if current_user

    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered successfully"
      redirect_to(user_url(:id => @user.id)) 
    else
      render :action => :new
    end
  end
end
