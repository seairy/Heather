lock '3.6.1'

set :scm, :git
set :application, 'Okra'
set :repo_url, 'git@github.com:seairy/Heather.git'
set :deploy_to, '/srv/www/Heather'
set :keep_releases, 5
set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/system}
set :use_sudo, false

namespace :deploy do
  namespace :passenger do
    desc 'Restart passenger server'
    task :restart do
      on roles(:app) do
        within current_path do
          execute :touch, 'tmp/restart.txt'
        end
      end
    end
  end
end
after 'deploy', 'deploy:passenger:restart'
