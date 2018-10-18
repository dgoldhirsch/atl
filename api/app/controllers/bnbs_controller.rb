class BnbsController < ApplicationController
  def index
    data = Bnb.order(:name).map do |bnb|
      { "name" => bnb.name, "number_of_votes" => bnb.number_of_votes }
    end

    respond_to do |format|
      format.json { render json: data.to_json }
      format.any { head :unsupported_media_type }
    end
  end
end
