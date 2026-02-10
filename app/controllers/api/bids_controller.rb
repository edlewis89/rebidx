module Api
  class BidsController < ApplicationController
    before_action :authenticate_user! # Devise auth

    def index
      bids = Bids.all
      render json: bids
    end

    def show
      bid = Bid.find(params[:id])
      render json: bid
    end

    def create
      bid = current_user.bids.build(bid_params)
      if bid.save
        render json: bid, status: :created
      else
        render json: { errors: bid.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def bid_params
      params.require(:bid).permit(:user_id, :listing_id, :amount, :message, :terms, :status)
    end
  end
end