class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bid

  def new
    # Show payment page with bid details
  end

  def create
    # Placeholder logic: mark bid as paid
    @bid.update!(status: :paid)
    @bid.listing.update!(status: :awarded)

    redirect_to homeowner_dashboard_path, notice: "Payment successful. Bid completed."
  end

  private

  def set_bid
    @bid = Bid.find(params[:bid_id])
    authorize @bid # Optional: Pundit check
  end
end
