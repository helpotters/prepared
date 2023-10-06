 module DatabaseHelper
   require "active_record"

   class DatabaseManager
     def initialize(database_name)
       @db_config = Rails.configuration.database_configuration["#{database_name}"]
       establish_connection
     end

     def establish_connection
       # Create a new connection
       @db_connection = ActiveRecord::Base.establish_connection("postgres://postgres:postgres@cache:5433/prepared_development")
     end

     def check_readyset_status
       result = execute_sql("SHOW READYSET STATUS;")
       result.values.to_h["Snapshot Status"] == "Completed"
     end

     def create_cache(query, name = nil, always: false)
       raise ArgumentError, "Query must operate on a READONLY table." unless query_readonly?(query)

       cache_command = "CREATE CACHE ALWAYS #{name} FROM #{query};"
       execute_sql(cache_command)
     end

     def verify_cache(query_id)
       result = execute_sql("SHOW CACHES WHERE query_id = '#{query_id}';")
       !result.empty? && result[0]["name"] == query_id
     end

     def show_caches
       result = execute_sql("SHOW CACHES;")
       p result.values
     end

     private

     def execute_sql(sql)
       @db_connection.connection.execute(sql)
     end

     def query_readonly?(query)
       true
     end
   end
 end
