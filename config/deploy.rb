set :application, "main_rails_app"
set :user, "psadmin"
set :runner, user
set :main_server, "demo.dormbuys.com"

set :scm, "git"
set :repository,  "ssh://git@git.parkersmithsoftware.com:30000dormbuys.git"
set :ssh_options, {:forward_agent => true}
set :port, 30000
set :use_sudo, true

set :deploy_to, "/var/www/apps/#{application}"

set :deploy_via, :remote_cache
#set :deploy_via, :copy



# setup the servers
# setup the servers
set :domain, main_server
role :app, main_server
role :web, main_server
role :db,  main_server, :primary => true


namespace :deploy do
  
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
  




after "deploy:start", "dj:start"
after "deploy:stop", "dj:stop"

before "deploy:update_code", "dj:stop"
after "deploy:restart_passenger", "dj:start"

# delayed_job
namespace :dj do
  
  desc "Start delayed_job daemon."
  task :start, :roles => :app do
    sudo "echo 'testing sudo'"
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=production script/delayed_job start; fi"
  end
  
  desc "Stop delayed_job daemon."
  task :stop, :roles => :app do
    sudo "echo 'testing sudo'"
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=production script/delayed_job stop; fi"
  end

  desc "Restart delayed_job daemon."
  task :restart, :roles => :app do
    sudo "echo 'testing sudo'"
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=production script/delayed_job restart; fi"
  end

  desc "Show delayed_job daemon status."
  task :status, :roles => :app do
    sudo "echo 'testing sudo'"
    run "if [ -d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=production script/delayed_job status; fi"
  end

  desc "List the PIDs of all running delayed_job daemons."
  task :pids, :roles => :app do
    sudo "echo 'testing sudo'"
    run "sudo lsof | grep '#{deploy_to}/shared/log/delayed_job.log' | cut -c 1-21 | uniq | awk '/^ruby/ {if(NR > 0){system(\"echo \" $2)}}'"
  end

  desc "Kill all running delayed_job daemons."
  task :kill, :roles => :app do
    sudo "echo 'testing sudo'"
    run "sudo lsof | grep '#{deploy_to}/shared/log/delayed_job.log' | cut -c 1-21 | uniq | awk '/^ruby/ {if(NR > 0){system(\"kill -9 \" $2)}}'"
    run "if [-d #{current_path} ]; then cd #{current_path} && sudo RAILS_ENV=production script/delayed_job stop; fi" # removes orphaned pid file(s)
  end
  
end


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
