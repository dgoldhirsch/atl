require "rails_helper"

describe "Use of Voting API" do
  shared_examples "it recorded votes totaling" do |new_total|
    before { get "/bed_and_breakfasts.json" }

    it "gets the expected B&B tuple" do
      expect(response).to be_successful
      tuples = JSON.parse(response.body)
      expect(tuples).to contain_exactly({ "name" => "Alan Turing Inn", "total_votes" => new_total })
    end
  end

  describe "A New Voter Votes on a New B&B" do
    before { post "/votes?bnb_name=Alan%20Turing%20Inn&first_name=Bette&last_name=Davis&number_of_votes=1" }

    it { expect(response).to be_created }
    it_behaves_like "it recorded votes totaling", 1
  end

  describe "A New Voter Adds Votes an Existing B&B" do
    before do
      post "/votes?bnb_name=Alan%20Turing%20Inn&first_name=Bette&last_name=Davis&number_of_votes=1"
      post "/votes?bnb_name=Alan%20Turing%20Inn&first_name=Bullwinkle&last_name=Moose&number_of_votes=4"
    end

    it { expect(response).to be_created }
    it_behaves_like "it recorded votes totaling", 5
  end

  describe "An Existing Voter Revises Their Vote" do
    before do
      post "/votes?bnb_name=Alan%20Turing%20Inn&first_name=Bette&last_name=Davis&number_of_votes=1" # replaced by...
      post "/votes?bnb_name=Alan%20Turing%20Inn&first_name=Bette&last_name=Davis&number_of_votes=2" # ...this
      post "/votes?bnb_name=Alan%20Turing%20Inn&first_name=Bullwinkle&last_name=Moose&number_of_votes=4"
    end

    it { expect(response).to be_created }
    it_behaves_like "it recorded votes totaling", 6
  end

  describe "A Malformed or Otherwise Unprocessable Vote is Attempted" do
    context "when the name of the B&B is omitted" do
      before { post "/votes?first_name=Bette&last_name=Davis&number_of_votes=1" }

      it { expect(response.status).to eq(Rack::Utils.status_code(:unprocessable_entity)) }
    end

    context "when the payload of the vote is invalid" do
      before do
        post "/votes?bnb_name=Alan%20Turing%20Inn" # Missing other params
      end

      it { expect(response.status).to eq(Rack::Utils.status_code(:unprocessable_entity)) }
    end
  end

  # describe "An Unauthorized User Tries to Vote" do
  #   before do
  #     set_up_as_unauthorized_user
  #
  #     post "/votes?bnb_name=Alan%20Turing%20Inn&voter_name=Bette%20Davis&number_of_votes=4"
  #   end
  #
  #   it { expect(response).to be_unauthorized }
  # end
end
