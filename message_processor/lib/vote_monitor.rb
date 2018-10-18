require "pry"
require "bunny"
require "faraday"
require "json"

class VoteMonitor
  def monitor
    connection = Bunny.new # TODO? Configure based on development vs. production, in real life?
    connection.start
    channel = connection.create_channel
    queue = channel.queue("vote_monitor_feed", durable: true)

    begin
      loop do
        queue.subscribe(block: true) do |_delivery_info, _properties, message|
          bnb_name, number_of_votes, first_name, last_name = parse_message(message)
          api_response = post_vote_to_api(bnb_name, number_of_votes, first_name, last_name)

          if api_response.status >= 500
            # TODO? How should we handle an operational failure from the server?
            puts "*** Server Error (#{api_response.status}) ***"
            puts api_response.body
          elsif !api_response.success?
            # TODO? How should we handle a bad message received in good faith?
            puts "*** POST Failed (#{api_response.status}): #{api_response.env.url}"
            puts message
          end
        end
      end
    rescue Interrupt => _
      connection.close
    end
  end

  private

  def parse_message(string)
    hash = JSON.parse(string)

    bnb_name = hash["name"].strip # Reasonable precaution against malformed data
    number_of_votes = hash["vote"]
    first_name = hash["voter"]["first_name"]
    last_name = hash["voter"]["last_name"]

    return bnb_name, number_of_votes, first_name, last_name
  end

  def post_vote_to_api(bnb_name, number_of_votes, first_name, last_name)
    # TODO Base of URL should be kept in an ENV or secrets file, and will probably be different in production
    base_url = "http://localhost:3000"

    # TODO? Wrap in some kind of rescue block, perhaps with some kind of retry?
    Faraday.post(
      base_url +
      "/votes?bnb_name=#{bnb_name}&first_name=#{first_name}&last_name=#{last_name}&number_of_votes=#{number_of_votes}"
    )
  end
end
