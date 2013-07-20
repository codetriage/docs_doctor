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
  if defined?(Resque)
    ENV["OPENREDIS_URL"] ||= "redis://127.0.0.1:6379"
    uri = URI.parse(ENV["OPENREDIS_URL"])
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    Rails.logger.info('Connected to Redis')
  end
end
