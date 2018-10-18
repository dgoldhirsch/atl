class Vote < ApplicationRecord
  belongs_to :bnb

  validates :number_of_votes, numericality: { only_integer: true } # TODO? Do we care about preventing the number zero? Negative votes?
  validates :first_name, presence: true
  validates :last_name, presence: true
end
