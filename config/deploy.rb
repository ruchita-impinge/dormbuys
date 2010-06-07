set :application, "main_rails_app"
set :user, "psadmin"
set :runner, user
set :main_server, "beta.dormbuys.com"

set :gateway, "psadmin@beta.dormbuys.com"

set :scm, "git"
set :repository,  "ssh://psadmin@parkersmithsoftware.com:30000/var/git/dormbuys_3_0.git"
set :ssh_options, {:forward_agent => true}
set :port, 30000
set :use_sudo, true

set :deploy_to, "/var/www/apps/#{application}"

set :deploy_via, :remote_cache
#set :deploy_via, :copy



# setup the servers
set :web1, "dormbuys-web1.dormbuys.com:30000"
set :web2, "dormbuys-web2.dormbuys.com:30000"
set :db1, "dormbuys-db1.dormbuys.com:30000"

set :domain, main_server
role :app, web2
role :app, web1, :primary => true
role :web, web1, web2
role :db, web1, :primary => true
#role :db, db1, :primary => true, :no_release => true


namespace :deploy do
  
  desc "Set permissions on dirs created in setup"
  task :after_setup do
    sudo "chown -R #{user}:#{user_group} #{deploy_to}"
    sudo "rm -rf #{deploy_to}/current"
  end
  
  desc "Copy shared resources after cold deploy"
  task :after_cold_deploy do 
    sudo "cp #{release_path}/config/database.yml #{shared_path}/database.yml"
  end
  
  desc "Default deploy - updated to run migrations"
  task :default do
    set :migrate_target, :latest
    update_code
    symlink
    symlink_resources
    migrate
    restart_passenger
  end

  
  desc "Symlink resource folders"
  task :symlink_resources do 
    
    sudo "rm -rf #{release_path}/config/database.yml"
    run "ln -sf #{shared_path}/database.yml #{release_path}/config/database.yml"
    
    sudo "rm -rf #{release_path}/public/content"
    run "ln -sf #{shared_path}/content #{release_path}/public/content"
    
  end
  
  
  desc "Restart Phusion Passenger"
  task :restart_passenger do 
    sudo "touch #{release_path}/tmp/restart.txt"
  end
  
  
  desc "Run this after every successful deployment" 
  task :after_default do
    cleanup
  end
end

deploy.task :start do end
  


namespace :delayed_job do
  desc "Start delayed_job process" 
  task :start, :roles => :app do
    run "cd #{current_path}; script/delayed_job start production" 
  end

  desc "Stop delayed_job process" 
  task :stop, :roles => :app do
    run "cd #{current_path}; script/delayed_job stop production" 
  end

  desc "Restart delayed_job process" 
  task :restart, :roles => :app do
    run "cd #{current_path}; script/delayed_job restart production" 
  end
end

after "deploy:start", "delayed_job:start" 
after "deploy:stop", "delayed_job:stop" 
after "deploy:restart_passenger", "delayed_job:restart"
