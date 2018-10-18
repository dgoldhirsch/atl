class BnbsController < ApplicationController
  def index
    data = Bnb.joins(:votes).group(:name).order(:name).sum(:number_of_votes).select.map do |name, total_votes|
      { "name" => name, "total_votes" => total_votes }
    end

    render json: data.to_json
  end
end
