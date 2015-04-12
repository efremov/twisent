class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_meta
  before_action :set_locale
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :not_found
  
  def set_meta
    set_meta_tags :title => 'Анализ тональности текста для твиттера', 
                  :description => 'Анализ тональности текста для твиттера.',
                  :keywords => 'анализ, тональность, твиттер, твит'
  end
  
  before_action :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || extract_locale
  end
  
  private
  
  def extract_locale  
    parsed_locale = request.host.split('.').last
    return locale.to_s.scan(/^[a-z]{2}/).first if (locale = request.env['HTTP_ACCEPT_LANGUAGE']) && (I18n.available_locales.map(&:to_s).include? locale.to_s.scan(/^[a-z]{2}/).first)
    false
  end
  
  def authenticate
    authenticate_token || render_unauthorized
  end
      
  def authenticate_token
    authenticate_with_http_token do |token, options|
      user = User.find_by(auth_token: token)
    end
    return user.present? && user == current_user
  end
  
      
  def render_unauthorized
    self.headers["WWW-Authenticate"] = 'Token realm="Twisent"'
    respond_to do |format|
      format.html {render status: 401}
      format.json { render json: {:errors => [{status: "Bad credentials", category_code: "authorization-failed", status_code: "401"}]}.to_json, status: 401 }
      format.xml { render xml: "Bad credentials", status: 401 }
    end        
  end
  
  def not_found
    respond_to do |format|
      format.html { render :file => File.join(Rails.root, 'public', '404.html'), :status => 404, layout: false }
      format.json { render :json => {:errors => [{status: "Not found", category_code: "not-found", status_code: "404"}]}.to_json, :status => 404 }
    end
  end
  
  
end
