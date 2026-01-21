class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_out_path_for(_resource_or_scope)
    flash[:notice] = "You have been logged out."
    new_user_session_path
  end
end
