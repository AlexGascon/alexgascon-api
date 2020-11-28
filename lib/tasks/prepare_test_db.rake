desc "Setup test database - drops, loads schema and migrates the test db"
task prepare_test_db: :environment do
  Rails.env = ENV['RAILS_ENV'] = 'test'
  Rake::Task['db:drop'].invoke
  Rake::Task['db:create'].invoke
  Rake::Task['db:schema:load'].invoke
  ActiveRecord::Base.establish_connection
  Rake::Task['db:migrate'].invoke
end
