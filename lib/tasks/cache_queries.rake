#!/usr/bin/env ruby
# lib/tasks/cache_queries.rake

namespace :cache do
  desc "Cache query statistics into another database"
  task :submit_queries => :environment do
    # Define the target database name
    target_database_name = "prepared_development"  # Replace with your target database name

    # Initialize the DatabaseManager for the target database
    database_manager = DatabaseHelper::DatabaseManager.new(target_database_name)

    # Check if the pg_stat_statements extension is installed
    extension_installed = ActiveRecord::Base.connection.execute(
      "SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements'"
    ).any?

    unless extension_installed
      puts "pg_stat_statements extension is not installed in the source database. Aborting..."
      return
    end

    # NOTE: Placeholder example of what the benchmarking queries could be
    # It currently does work, but it still needs a way to filter out valid queries.
    queries = {
      "highest_load" => "total_exec_time DESC",
      "highest_latency" => "mean_exec_time DESC",
      "most_issued" => "calls DESC",
    }

    queries.each do |category, order_by|
      puts "#{category}:"
      results = [
        'SELECT "definitions".* FROM "definitions" WHERE ("definitions"."word_id" = $1)',
        'SELECT "words".* FROM "words" WHERE ("words"."id" = $1)',
        'SELECT "words".* FROM "words" WHERE ("words"."id" = $1) ORDER BY "words"."id" ASC',
      ]
      # Cache each query result into the target database
      results.each do |query|
        database_manager.create_cache(query, "#{category}_#{SecureRandom.hex}")
        puts "Cached query: #{query}"
      end

      puts "\n"
    end
  end
  task :check_status => :environment do
    # Define the target database name
    target_database_name = "prepared_development"  # Replace with your target database name

    # Initialize the DatabaseManager for the target database
    database_manager = DatabaseHelper::DatabaseManager.new(target_database_name)

    database_manager.check_readyset_status
  end
  task :view_caches => :environment do
    # Define the target database name
    target_database_name = "prepared_development"  # Replace with your target database name

    # Initialize the DatabaseManager for the target database
    database_manager = DatabaseHelper::DatabaseManager.new(target_database_name)

    database_manager.show_caches
  end
end
