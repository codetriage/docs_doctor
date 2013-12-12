WEB_CONCURRENCY = Integer(ENV['WEB_CONCURRENCY']|| 3)


threads 1,5
workers WEB_CONCURRENCY
preload_app!

on_worker_boot do
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  # If you are using Redis but not Resque, change this

  Resque.redis.redis.client.reconnect if Q.env.resque?
end
