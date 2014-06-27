require "rvm/capistrano"
require "bundler/capistrano"
require "dotenv/deployment/capistrano"
require 'dotenv'
Dotenv.load

set :bundle_without, [:darwin, :development, :test]
set :application, "sheepdog"

set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
set :repository,  "git@github.com:Diggerlab/sheepdog.git"
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache

set :branch, "master"
set :user, ENV['DEPLOY_USER']
set :use_sudo, false
set :scm, :git

set :deploy_to, ENV['DEPLOY_FOLDER']
set :current_path, "#{deploy_to}/current"
set :releases_path, "#{deploy_to}/releases/"
set :shared_path, "#{deploy_to}/shared"


role :web, ENV['DEPLOY_WEB_SERVER']                          # Your HTTP server, Apache/etc
role :app, ENV['DEPLOY_APP_SERVER']                         # This may be the same as your `Web` server

set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace:deploy do
    task :start_unicorn, :roles => :app do
      run "cd #{current_path} && bundle exec unicorn -c #{unicorn_config} -D"
    end

    task :stop_unicorn, :roles => :app do
      run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
    end

    task :restart_unicorn, :roles => :app do
      run "if [ -f #{unicorn_pid} ]; then kill -s USR2 `cat #{unicorn_pid}`; fi"
    end

    namespace:app do 
      task:start do
      end
      
      task:stop do
      end

      # before "deploy:finalize_update" do 
      #   run "cp #{shared_path}/config/database.yml #{release_path}/config/"
      # end

      after "deploy:restart", :roles => :app do
        after "deploy:restart", "deploy:restart_unicorn"
      end
    end

end