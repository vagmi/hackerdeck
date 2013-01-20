require 'rubygems'
require 'bundler'
require 'logger'
Bundler.require :default


namespace :db do
  task :environment do
    require './models'
  end
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end
