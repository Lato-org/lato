SIDEKIQ_REDIS_CONFIGURATION = {
  url: "#{ENV['REDIS_URL'] || 'redis://localhost:6379'}/0"
}

Sidekiq.configure_server do |config|
  config.redis = SIDEKIQ_REDIS_CONFIGURATION
end

Sidekiq.configure_client do |config|
  config.redis = SIDEKIQ_REDIS_CONFIGURATION
end
