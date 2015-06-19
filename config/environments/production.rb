Rails.application.configure do
  config.cache_classes = true
  config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
  config.assets.precompile += %w( .svg .eot .woff .ttf )
  config.eager_load = true
  


  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.cache_store = :dalli_store
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.serve_static_assets = false

  #config.action_controller.asset_host = "d34oukadfdb4o8.cloudfront.net"
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass
  config.assets.compile = false
  config.assets.digest = true
  config.assets.version = '1.0'
  config.log_level = :warn
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
end
