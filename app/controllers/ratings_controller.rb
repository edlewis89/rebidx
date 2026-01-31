class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bid

  def create
    @bid = Bid.find(params[:bid_id])
    @provider = @bid.user.service_provider_profile

    @rating = @provider.ratings.new(rating_params)
    @rating.user = current_user
    @rating.bid = @bid   # ✅ THIS WAS MISSING

    if @rating.save
      redirect_to homeowner_dashboard_path(@provider), notice: "Rating submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    # only allow if job is completed and not yet rated
    if @bid.complete? && @bid.rating.nil?
      @rating = @bid.build_rating
    else
      redirect_to homeowner_dashboard_path, alert: "You cannot rate this job yet."
    end
  end

  private

  def set_bid
    @bid = Bid.find(params[:bid_id]) # find the bid directly

    # ensure current_user is the owner of the listing
    unless @bid.listing.user == current_user
      redirect_to homeowner_dashboard_path, alert: "You are not authorized to rate this provider." and return
    end
  end

  def rating_params
    params.require(:rating).permit(:score, :comment)
  end
end
