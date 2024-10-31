class ApplicationController < ActionController::Base
  helper_method :current_user, :authenticate_user
  def current_user
    User.find(session[:user_id]) if session[:user_id].present?
  end

  def authenticate_user
    redirect_to login_path if current_user.blank?
  end
end
