require "rails_helper"

describe BnbsController do
  describe "#index" do
    before do
      allow(Bnb).to receive_message_chain(:joins, :group, :order, :sum).with(:number_of_votes).and_return(
        [["Sally's Suites Inn", 3], ["Tetley's Teeth Hotel", 0]]
      )

      get :index, format: :json
    end

    it { expect(response).to be_successful }

    it "returns the list of B&B tuples" do
      array = JSON.parse(response.body)

      expect(array).to contain_exactly(
        { "name" => "Sally's Suites Inn", "total_votes" => 3 },
        { "name" => "Tetley's Teeth Hotel", "total_votes" => 0 }
      )
    end

    # TODO Check for unauthorized use
    # context "when user is unauthorized" do
    #   before do
    #     set_up_as_unauthorized_user
    #
    #     get :index, format: :json
    #   end
    #
    #   it { expect(response).to be_unauthorized }
    # end
  end
end
