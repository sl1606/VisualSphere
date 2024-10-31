class SessionsController < ApplicationController
  before_action :authenticate_user, only: [:destroy]

  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user.present? && @user.password_hash == params[:password]
      session[:user_id] = @user.id
      redirect_to db_connections_path, notice: 'Logged in successfully'
    else
      redirect_to '/login', notice: 'Invalid email or password'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end