require "bunny"
require "json"

class TestDriver
  attr_accessor :channel
  attr_accessor :queue

  def initialize
    connection = Bunny.new # TODO? Configure based on development vs production, in real life?
    connection.start
    self.channel = connection.create_channel
    self.queue = channel.queue("vote_monitor_feed", durable: true)

    puts %~Ready to push!  Try something like this:  t.push("Blessing Inn", 2, "Johnny", "Quest")~
  end

  def push(bnb_name, vote, first_name, last_name)
    message = JSON.generate({ name: bnb_name, vote: vote, voter: { first_name: first_name, last_name: last_name } })
    channel.default_exchange.publish(message, routing_key: queue.name)
  end
end
