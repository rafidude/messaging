require 'em-redis'
require './db'
EM.run do
  EM.add_periodic_timer(2) do
    puts "Tick... every 2 secs"
    fetch = true
    begin
      message_key = DB.db.lpop "messageQ"
      puts "Message Key: " + message_key if message_key
      DB.push_to_subscribers(message_key) if message_key
      fetch = false unless message_key
    end while fetch
  end
  
  EM.add_periodic_timer(5) do
    puts "Every 5 secs Tick..."
    # Fetch latest user subscriptions from SQL and cache the data in redis
    # DBSQL.get_user_subscriptions
    DB.populate_channels_with_subscribed_users
  end
end


require 'em-redis'
require './db'
EM.run do
  redis = EM::Protocols::Redis.connect
  redis.errback do |code|
    puts "Error code: #{code}"
  end
  EM.add_periodic_timer(2) do
    puts "Tick... every 2 secs"
    fetch = true
    begin
      redis.lpop "messageQ"
      puts "Message Key: " + message_key if message_key
      redis.hget message_key, 'channels' do |channel_str|
        puts channel_str
        channels = channel_str.split(',')
        channels.each do |channel|
          channel.lstrip!
          redis.smembers channel do |subscribed_users|
            subscribed_users.each do |user_key|
              redis.sadd 'MB.' + user_key, message_key
            end
          end
        end
      end
      fetch = false unless message_key
    end while fetch
  end
  
  EM.add_periodic_timer(5) do
    puts "Every 5 secs Tick..."
    # Fetch latest user subscriptions from SQL and cache the data in redis
    # DBSQL.get_user_subscriptions
    DB.populate_channels_with_subscribed_users
  end
end


