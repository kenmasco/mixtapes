class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    [:name, :location, :male, :birthday, :image_url].each do |parameter|
      devise_parameter_sanitizer.for(:account_update) << parameter
    end
  end

  def devise_mapping
    @devise_mapping ||= request.env["devise.mapping"]
  end

  def resource_name
    @devise_mapping.name
  end

  def resource_class
    @devise_mapping.to
  end

  def after_sign_in_path_for resource
    if resource.mixtape.nil?
      new_mixtape_path
    else
      mixtapes_path
    end
  end

end