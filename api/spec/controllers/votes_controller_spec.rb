require "rails_helper"

describe VotesController do
  describe "#create" do
    let(:carlys_hotel) { double(name: "Carly's Hotel") }
    let(:vote) { double(valid?: true, save!: true, :number_of_votes= => true) }

    before do
      allow(Bnb).to receive(:find_or_create_by!).with(name: "Carly's Hotel").and_return(carlys_hotel)
      allow(Vote).to receive(:find_or_initialize_by).with(bnb: carlys_hotel, first_name: "Adam", last_name: "West").and_return(vote)
    end

    it "creates the vote" do
      post :create, params: { bnb_name: "Carly's Hotel", first_name: "Adam", last_name: "West", number_of_votes: 4 }

      expect(vote).to have_received(:number_of_votes=).with("4")
      expect(vote).to have_received(:save!)
    end

    shared_examples "an_error" do |error_code|
      it { expect(response.status).to eq(error_code) }
      it { expect(vote).not_to have_received(:save!) }
    end

    context "when the name of the B&B is omitted" do
      before do
        allow(Bnb).to receive(:find_by).with(name: nil)

        post :create, params: { first_name: "Adam", last_name: "West", number_of_votes: 4 }
      end

      it_behaves_like "an_error", Rack::Utils.status_code(:unprocessable_entity)
    end

    context "the vote data is invalid" do
      before do
        allow(vote).to receive(:valid?).and_return(false)

        post :create, params: { bnb_name: "Carly's Hotel", first_name: "Adam", last_name: "West" } # i.e., missing number of votes
      end

      it_behaves_like "an_error", Rack::Utils.status_code(:unprocessable_entity)
    end

    # TODO Check for unauthorized use
    # context "when user is unauthorized" do
    #   before do
    #     set_up_as_unauthorized_user
    #
    #     post :create, { bnb_name: whatever, voter_name: whatever_else }
    #   end
    #
    #   it { expect(response).to be_unauthorized }
    # end
  end
end
