class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		log_in user #log_in user method from SessionsHelper
       params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user #Rails auto converts this to the route for the user’s profile page: user_url(user)
  	else
  		flash.now[:danger] = "Invalid email/password combination"
  		render 'new'
  	end
  end

  def destroy
    log_out if logged_in? #log_out method form SessionsHelper
    redirect_to root_url
  end

end
