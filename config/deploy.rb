require "rvm/capistrano"
require "bundler/capistrano"

#set :whenever_command, "bundle exec whenever"

default_run_options[:pty] = true

set :rvm_type, :system
set :application, "twisent"
set :rails_env, "production"
set :repository, "."
set :deploy_to, "/var/www/#{application}" #path to your app on the production server 

set :scm, :git
set :branch, "master"
set :deploy_via, :copy
set :shallow_clone, 1

set :user, "efremov" #this is the ubuntu user we created
set :password, "mEsqueunclubf00" #deploy's password
set :use_sudo, false


set :domain, 'datmachine.co'
role :web, domain
role :app, domain



after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "deploy:write_crontab"

namespace :deploy do
  desc "Write the crontab file"
  task :write_crontab do
    run "cd #{latest_release} && bundle exec whenever --write-crontab #{application}"
  end
end


