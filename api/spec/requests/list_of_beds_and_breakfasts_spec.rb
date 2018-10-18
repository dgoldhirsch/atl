require "rails_helper"

describe "Getting the List of B&Bs, Each With Its Current, Total Votes" do
  before do
    ati = FactoryBot.create(:bnb, name: "Alan Turing Inn")
    ati.votes.create!(first_name: "John", last_name: "Wayne", number_of_votes: 1)
    ati.votes.create!(first_name: "Philip", last_name: "Glass", number_of_votes: 2)

    bbh = FactoryBot.create(:bnb, name: "Betty Boop Hotel")
    bbh.votes.create!(first_name: "Sandra", last_name: "Roth", number_of_votes: 0)

    get "/bed_and_breakfasts.json"
  end

  it { expect(response).to be_successful }

  it "returns the list of B&Bs each with its total votes" do
    expect(JSON.parse(response.body)).to contain_exactly(
      { "name" => "Alan Turing Inn", "total_votes" => 3 },
      { "name" => "Betty Boop Hotel", "total_votes" => 0 }
    )
  end

  context "when there is no data" do
    before do
      Bnb.destroy_all

      get "/bed_and_breakfasts.json"
    end

    it { expect(response).to be_successful }
    it { expect(JSON.parse(response.body)).to be_empty }
  end

  # TODO In real life, there would be some kind of API authentication or at least a token of some kind,
  # for which we should have a test against unauthorized access, e.g.....
  #
  # context "when the user is unauthorized" do
  #   before do
  #     set_up_as_unauthorized_user
  #
  #     get "/bed_and_breakfasts.json"
  #   end
  #
  #   it { expect(response).to be_unauthorized }
  # end
end
