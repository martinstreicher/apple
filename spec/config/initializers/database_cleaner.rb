# frozen_string_literal: true

DatabaseCleaner.allow_production = false
DatabaseCleaner.allow_remote_database_url = false
DatabaseCleaner[:active_record].clean_with :truncation
DatabaseCleaner[:active_record].strategy = :transaction
DatabaseCleaner[:redis].strategy = :deletion
