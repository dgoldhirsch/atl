require "rails_helper"

describe Vote do
  it { should belong_to(:bnb) }
  it { should validate_numericality_of(:number_of_votes).only_integer }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
end
