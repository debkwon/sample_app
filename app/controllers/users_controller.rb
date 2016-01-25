class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

	include UsersHelper

  def index
    @users = User.paginate(page: params[:page]) 
    # User.paginate pulls the users out of the database one chunk at 
    # a time (30 by default), based on the :page parameter. So, for example, 
    # page 1 is users 1–30, page 2 is users 31–60, etc. If page is nil, paginate 
    # simply returns the first page. Here the page parameter comes from params[:page], 
    # which is generated automatically by will_paginate.
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      @user.send_activation_email #send_activation email method in Users model
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    #   log_in @user #log in user immediately if there's no acct activation required
  		# flash[:success] = "Welcome to the Sample App"
  		# redirect_to @user
  	else 
  		render 'new'
  	end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id]) 
    if @user.update_attributes(user_params) #update user based on submitted user_params
      flash[:success] = "Profile successfully updated!"
      redirect_to @user
    else
      render 'edit' #if there's an unsuccessful edit, render the edit page again
    end
  end

  
def correct_user
  @user = User.find(params[:id])
  redirect_to(root_url) unless current_user?(@user) # we added a current_user? method to sessions helper. same as @user == current_user
end

def destroy
  User.find(params[:id]).destroy
  flash[:success] = "User deleted"
  redirect_to users_url
end

def admin_user
  redirect_to(root_url) unless current_user.admin?
end

#######################################
  #added user_params to users_helper



end
