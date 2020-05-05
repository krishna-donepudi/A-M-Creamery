class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # handle 404 errors with an exception as well
  rescue_from ActiveRecord::RecordNotFound do |exception|

    # consider creating your own 404 page within home and redirecting there...
    
    flash[:error] = "This path does not exist or you are not permitted through here"
    redirect_to home_path
  end
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Nothing to see here"
    redirect_to home_path
  end


  private
  def current_user
    @current_user ||= Employee.find(session[:employee_id]) if session[:employee_id]
  end
  helper_method :current_user

  def logged_in?
    current_user
  end
  helper_method :logged_in?

  def check_login
    redirect_to login_url, alert: "You need to log in to view this page." if current_user.nil?
  end
  
end
