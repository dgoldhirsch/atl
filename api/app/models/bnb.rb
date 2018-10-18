class Bnb < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :votes, dependent: :destroy
end
