class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale

  private

  rescue_from ActiveResource::UnauthorizedAccess do |e|
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end

  def close_session
    Rails.logger.info '------- closing session'
    session[versacommerce] = nil
    redirect_to login_path
  end

  def extract_locale_from_accept_language_header
    browser_locale   = request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /^[a-z]{2}/).try(:first).try(:to_sym)
    session[:locale] = browser_locale if I18n.available_locales.include? browser_locale
  end

  def set_locale
    extract_locale_from_accept_language_header if session[:locale].blank?
    session[:locale] = I18n.default_locale if session[:locale].blank?
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale]
    Rails.application.routes.default_url_options[:locale]= I18n.locale
  end

  def ensure_api_session
    if session[:versacommerce]
      Rails.logger.info '--------- session present'
      logger.info session[:versacommerce].valid? ? "----------- session valid" : "----------- session invalid"
      VersacommerceAPI::Base.activate_session(session[:versacommerce])
      Rails.logger.info '--------- session activated'
    else
      Rails.logger.info '--------- session not active'
      session[:return_to] = request.fullpath if request.get?
      redirect_to login_path(shop: params[:shop])
    end
  end

end
