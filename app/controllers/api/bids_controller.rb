module Api
  class BidsController < Api::BaseController

    def index
      bids = current_user.bids
      render json: bids
    rescue => e
      render json: { status: 500, error: e.message }, status: :internal_server_error
    end

    def show
      bid = current_user.bids.find(params[:id])
      render json: bid
    rescue => e
      render json: { status: 500, error: e.message }, status: :internal_server_error
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
      params.require(:bid).permit(:listing_id, :amount, :message, :terms, :status)
    end
  end
end