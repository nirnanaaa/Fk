
require 'bundler/capistrano'
require 'sidekiq/capistrano'
require 'capistrano-helpers/specs'

require "rvm/capistrano"

set :repository, 'git://github.com/nirnanaaa/fk.git'
set :deploy_via, :remote_cache
set :branch, fetch(:branch, 'master')
set :scm, :git
set :port, 1025
ssh_options[:forward_agent] = true
set :ding, true

set :rvm_ruby_string, '2.0.0'
# General Settings
set :deploy_type, :deploy
default_run_options[:pty] = true

# Server Settings
set :user, 'deployer'
set :use_sudo, false
set :rails_env, :production

role :app, 'zyg.li', primary: true
role :db,  'zyg.li', primary: true
role :web, 'zyg.li', primary: true

# Application Settings
set :application, 'fk'
set :deploy_to, "/srv/web/#{application}"

set :default_environment, { 
  'PUMA_PATH' => current_path
}
# Perform an initial bundle
after "deploy:setup" do
  run "cd #{current_path} && bundle install"
end

# Tasks to start/stop/restart thin
namespace :deploy do
  desc 'Start puma servers'
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=production bundle exec puma -e production -C ./config/puma.rb", :pty => false
  end

  desc 'Stop puma servers'
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec pumactl -F ./config/puma.rb stop"
  end

  desc 'Restart puma servers'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec pumactl -F ./config/puma.rb restart"
  end
  desc 'Links the database configuration'
  task :link_database, :roles => :app, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
  end  
  

  
  desc 'Create db'
  task :createdb do
    run "psql -c 'create database Ul_production;' -U postgres"
  end
  

end

# Symlink config/nginx.conf to /etc/nginx/sites-enabled. Make sure to restart
# nginx so that it picks up the configuration file.
# namespace :config do
#   task :nginx, roles: :app do
#     puts "Symlinking your nginx configuration..."
#     sudo "ln -nfs #{release_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
#   end
# end
# 
# after "deploy:setup", "config:nginx"

# Seed your database with the initial production image. Note that the production
# image assumes an empty, unmigrated database.
# namespace :db do
#   desc 'Seed your database for the first time'
#   task :seed do
#     run "cd #{current_path} && psql -d discourse_production < pg_dumps/production-image.sql"
#   end
# end

# Migrate the database with each deployment
before "deploy:assets:precompile", 'deploy:link_database'
#before 'deploy:update_code', 'deploy:apt'
after  'deploy:update_code', 'deploy:migrate'