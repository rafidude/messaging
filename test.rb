require './db'

def setup_db
  DB.db.flushdb
  DB.db.sadd "subs.user#1", "c1"
  DB.db.sadd "subs.user#1", "c3"
  DB.db.sadd "subs.user#2", "c2"
  DB.db.sadd "subs.user#2", "c3"
  DB.db.sadd "subs.user#3", "c1"
  DB.db.sadd "subs.user#3", "c2"
end

setup_db
DB.populate_channels_with_subscribed_users

def send_test_message(number_of_messages)
  number_of_messages.times do |iter|
    ch1 = 1 + rand(3)
    ch2 = 1 + rand(3)
    ch_str = 'c' + ch1.to_s + ', ' + 'c' + ch2.to_s
    ch_str = 'c' + ch1.to_s if ch1 == ch2
    random_user = 1 + rand(3)
    usr_str = "user#" + random_user.to_s
    #puts "User: #{usr_str} sending message to channels #{ch_str}"
    message = {:title=>"This is title #{iter}", 
      :description=>"#{iter}: Here is a detailed description for #{iter}", 
      :channels=>ch_str, :from => usr_str}
    key = DB.send(message)
  end
end

#count = 2000
count = 2
send_test_message(count)
puts "Sent #{count} messages"

# puts "Message Key: " + message_key
# message_key = DB.db.lpop "messageQ"
# DB.push_to_subscribers(message_key) if message_key
