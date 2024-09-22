class RentalsController < ApplicationController
  def index
    @rentals = current_user.rentals
    render json: @rentals
  end

  def show
    @rental = current_user.rentals.find(params[:id])
    render json: @rental
  end
end
