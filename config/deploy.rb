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


namespace:deploy do
    namespace:app do 
      task:start do
      end
      
      task:stop do
      end

      # before "deploy:finalize_update" do 
      #   run "cp #{shared_path}/config/database.yml #{release_path}/config/"
      # end

      after "deploy:restart", :roles => :app do
        #add any tasks in here that you want to run after the project is deployed
        run "rm -rf #{release_path}.git"
        run "chmod -R 755 #{current_path}"
        run "touch #{File.join(current_path,'tmp','restart.txt')}"
        
      end
    end

end