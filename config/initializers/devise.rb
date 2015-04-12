Devise.setup do |config|
  config.mailer_sender = 'support@datmachine.ru'
  require 'devise/orm/mongoid'
  
  config.omniauth :facebook, "539050852903473", "0ceb91252342b0fc4f9c81ef90eba731"
  config.omniauth :twitter, "CEV4wHSjQifzW5y7TPnhWB9Qz", "wFBcxUVEa9wJfcJzYUdd1wFYycc91zSYF53kr509t8NcJOeMMz"
  #config.omniauth :twitter, "j0YUZ9LpKVXQjSq7knYz1Gtxy", "Dx06n1d6bA4TdbbTX6jQ6cVfMWLdPXrymObtGo0lo3HRvJ2qmJ"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end
