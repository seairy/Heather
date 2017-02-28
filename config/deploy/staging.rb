# -*- encoding : utf-8 -*-
set :stage, :staging
set :branch, 'master'
set :rvm_type, :user
set :rvm_ruby_version, '2.2.4'
set :deploy_user, 'deploy'

server '60.205.167.123', user: 'deploy', roles: %w{web app db}

set :rails_env, :development
