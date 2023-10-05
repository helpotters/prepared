# lib/tasks/pg_queries.rake

namespace :pg_queries do
  desc "Display PostgreSQL query statistics"
  task :display_statistics => :environment do
    # Check if pg_stat_statements extension is installed
    extension_installed = ActiveRecord::Base.connection.execute(
      "SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements'"
    ).any?

    unless extension_installed
      puts "pg_stat_statements extension is not installed. Installing..."
      ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_stat_statements")
      puts "pg_stat_statements extension installed."
      puts "Please restart the database for changes to take effect."
      return
    end

    queries = {
      "highest load" => "total_exec_time DESC",
      "most issued" => "calls DESC",
    }

    queries.each do |category, order_by|
      puts "#{category}:"
      results = ActiveRecord::Base.connection.execute(
        "SELECT query, calls, total_exec_time, mean_exec_time " \
        "FROM pg_stat_statements WHERE query ILIKE '%SELECT%' ORDER BY #{order_by} LIMIT 3"
      )

      print_query_results(results)
      puts "\n"
    end
  end

  def print_query_results(results)
    table = Terminal::Table.new do |t|
      t.headings = ["Query", "Calls", "Total Exec Time", "Mean Exec Time"]
      results.each do |row|
        t << [row["query"], row["calls"], row["total_exec_time"], row["mean_exec_time"]]
      end
    end

    puts table
  end
end
