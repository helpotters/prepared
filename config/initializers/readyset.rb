#!/usr/bin/env ruby
Readyset.configure do |config|
  # Whether the gem's automatic failover feature should be enabled.
  config.failover.enabled = false
  # Sets the interval upon which the background task will check
  # ReadySet's availability after failover has occurred.
  config.failover.healthcheck_interval = 5.seconds
  # Sets the time window over which connection errors are counted
  # when determining whether failover should occur.
  config.failover.error_window_period = 1.minute
  # Sets the number of errors that must occur within the configured
  # error window period in order for failover to be triggered.
  config.failover.error_window_size = 10
  # The file in which cache migrations should be stored.
  config.migration_path = File.join(Rails.root, 'db/readyset_caches.rb')
end
