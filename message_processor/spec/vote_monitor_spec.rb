require_relative "spec_helper"

describe VoteMonitor, type: :unit do
  let(:connection) { double(start: true, close: true) }
  let(:channel) { double }
  let(:queue) { double }

  let(:delivery_info) { double }
  let(:properties) { double }

  let(:body) do
    JSON.generate({
      "name" => "Howard's Inn",
      "vote" => "16",
      "voter" => {
        "first_name" => "Alfred",
        "last_name" => "Newman"
      }
    })
  end

  before do
    allow(Bunny).to receive(:new).and_return(connection)
    allow(connection).to receive(:create_channel).and_return(channel)
    allow(channel).to receive(:queue).with("vote_monitor_feed", durable: true).and_return(queue)

    allow(queue).to receive(:subscribe).with(block: true) do |&original_block|
      original_block.call(delivery_info, properties, body)
      raise Interrupt # abort loop after this first callback
    end

    allow(Faraday).to receive(:post).and_return(double(status: 201, success?: true))

    subject.monitor
  end

  it "reads the vote from the queue and posts it to the server" do
    expect(Faraday).to have_received(:post).with(
      "http://localhost:3000/votes?bnb_name=Howard's Inn&first_name=Alfred&last_name=Newman&number_of_votes=16"
    )
  end
end
