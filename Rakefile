# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

DocsDoctorWeb::Application.load_tasks


$:.unshift File.expand_path 'lib'

require 'docs_doctor'

require 'docs_doctor/task'

require 'resque/tasks'


task "resque:setup" => :environment do
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
