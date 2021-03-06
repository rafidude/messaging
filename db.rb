require 'redis'
require 'uri'

class DB
  def self.initialize_redis
    #ENV["REDISTOGO_URL"] = 'redis://redistogo:50413146199119e2b7f2eca2c1e87f9e@catfish.redistogo.com:9465/'
    if ENV["REDISTOGO_URL"]
      uri = URI.parse(ENV["REDISTOGO_URL"])
      @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      @redis = Redis.new
    end
  end
  
  def self.db
    @redis
  end
  
  initialize_redis

  def self.send(message)
    id = db.incr 'message_seq'
    key = 'M#' + id.to_s
    db.hset key, 'from', message[:from]
    db.hset key, 'title', message[:title]
    db.hset key, 'description', message[:description]
    db.hset key, 'channels', message[:channels]
    db.rpush 'messageQ', key
    key
  end

  def self.my_messages(user_key)
    db.smembers 'MB.' + user_key
  end
  
  def self.push_to_subscribers(message_key)
    channel_str = DB.db.hget message_key, 'channels'
    channels = channel_str.split(',')
    channels.each do |channel|
      channel.lstrip!
      subscribed_users = DB.db.smembers channel
      subscribed_users.each do |user_key|
        DB.db.sadd 'MB.' + user_key, message_key
      end
    end
  end
  
  def self.populate_channels_with_subscribed_users
    subscriptions = db.keys "subs.user*"
    subscriptions.each do |sub|
      user_key = sub[5,sub.length]
      subscribed_channels = db.smembers sub
      subscribed_channels.each do |channel|
        db.sadd channel, user_key
      end
    end
  end
end
