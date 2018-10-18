require "rails_helper"

describe Bnb do
  it { should have_many(:votes).dependent(:destroy) }
  it { should validate_presence_of(:name) }
end
