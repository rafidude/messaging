require 'redis'

class DB
  def self.initialize_redis
    @db = Redis.new
  end
  
  initialize_redis

  def self.send(message)
    id = @db.incr 'message_seq'
    key = 'M#' + id
    @db.hset key, 'description', message.description
    @db.hset key, 'sic_codes', message.sic_codes
    # @db.rpush 'waitingQ', key
    # later depending on the load the following function
    # can be factored into an eventmachine process
    push_to_subscribers(key)
  end

  def self.my_messages(user_key)
    messages = []
    groups = @db.smembers user_key
    groups.each do |group|
      group_messages = @db.smembers group
      messages << group_messages
    end
    messages
  end
  
  private:
    def self.push_to_subscribers(message_key)
      sic_codes = @db.hget message_key, 'sic_codes'
      groups = sic_codes.split(',')
      groups.each do |group|
        @db.sadd group, message_key
      end
    end
end