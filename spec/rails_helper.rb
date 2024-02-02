# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'database_cleaner/active_record'
require 'database_cleaner/redis'
require 'rails/all'
require 'rspec/rails'
require 'shoulda/matchers'
require 'test_prof/recipes/rspec/let_it_be'

class Application < Rails::Application
  config.active_job.queue_adapter = :inline
end

File.expand_path(__dir__).tap do |spec_directory|
  Dir[File.join(spec_directory, 'config/initializers/**/*.rb')].each { |f| require f }
  Dir[File.join(spec_directory, 'support', '**', '*.rb')].each { |f| require f }
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
