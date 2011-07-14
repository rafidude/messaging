require 'eventmachine'
require './db'

EM.run do
  EM.add_periodic_timer(2) do
    t1 = Time.now
    # processing...
    puts "Tick... every 2 secs"
    fetch = true
    count = -1
    begin
      message_key = DB.db.lpop "messageQ"
      DB.push_to_subscribers(message_key) if message_key
      fetch = false unless message_key
      count += 1
    end while fetch
    t2 = Time.now
    delta = t2 - t1
    puts "completed processing #{count} messages" if count > 0
    puts delta if count > 0
  end
  
  EM.add_periodic_timer(10) do
    puts "Every 10 secs Tick..."
    # Fetch latest user subscriptions from SQL and cache the data in redis
    # DBSQL.get_user_subscriptions
    DB.populate_channels_with_subscribed_users
  end
end