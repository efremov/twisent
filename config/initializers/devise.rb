Devise.setup do |config|
  config.mailer_sender = 'support@datmachine.ru'
  require 'devise/orm/mongoid'
  
  config.omniauth :facebook, ENV["facebook_api_key"], ENV["facebook_api_secret"]
  config.omniauth :twitter, ENV["twitter_api_key"], ENV["twitter_api_secret"]

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end
