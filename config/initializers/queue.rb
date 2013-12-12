Q.setup do |config|
  config.queue = :resque
end

if Q.env.resque?
  require 'resque/server'

  ENV["REDIS_URL"] ||= ENV["OPENREDIS_URL"] ||= "redis://127.0.0.1:6379"
  uri = URI.parse(ENV["REDIS_URL"])

  Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
  Resque.redis.namespace = Rails.root.split.last.to_s
  Rails.logger.info('Connected to Redis')

  class MyResqueAuthentication
    def initialize(app)
      @app = app
    end

    def call(env)
      user = env['warden'].user
      raise "Cannot access protected resource as: #{user.inspect}" unless user.try(:admin?)
      @app.call(env)
    end
  end

  Resque::Server.use MyResqueAuthentication

  Rails.application.routes.prepend do
    mount Resque::Server.new, :at => "/codetriage/resque"
  end
end
