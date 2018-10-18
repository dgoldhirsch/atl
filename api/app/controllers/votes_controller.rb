class VotesController < ApplicationController
  def create
    head :unprocessable_entity and return unless permitted[:bnb_name].present?

    bnb = Bnb.find_or_create_by!(name: permitted[:bnb_name])
    vote = Vote.find_or_initialize_by(bnb: bnb, first_name: permitted[:first_name], last_name: permitted[:last_name])
    vote.number_of_votes = permitted[:number_of_votes]

    if vote.valid?
      vote.save!
      head :created # TODO? Return JSON representation of created/updated vote, in body?
    else
      head :unprocessable_entity # TODO? Return error message(s)?
    end
  end

  private

  def permitted
    @permitted ||= params.permit(:bnb_name, :first_name, :last_name, :number_of_votes)
  end
end
