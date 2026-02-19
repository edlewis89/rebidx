#  Any profile can bid, not just “service providers.”
#  Rating attaches to the actual profile that made the bid.
#  The homeowner (listing owner) is still the user that creates the rating.
#  Future-proof: if a user has multiple profiles (e.g., seller + provider), each profile can bid separately and be rated independently.

class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bid
  before_action :set_rated_profile

  def new
    if @bid.listing.user == current_user && @bid.complete? && @bid.rating.nil?
      @rating = @bid.build_rating
    else
      redirect_to homeowner_dashboard_path, alert: "You cannot rate this job yet."
    end
  end

  def create
    @rating = @rated_profile.ratings.new(rating_params)
    @rating.user = current_user  # homeowner
    @rating.bid = @bid

    if @rating.save
      redirect_to homeowner_dashboard_path(@rated_profile), notice: "Rating submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_bid
    @bid = Bid.find(params[:bid_id])
    unless @bid.listing.user == current_user
      redirect_to homeowner_dashboard_path, alert: "You are not authorized to rate this bid."
    end
  end

  def set_rated_profile
    @rated_profile = @bid.profile
    unless @rated_profile
      redirect_to homeowner_dashboard_path, alert: "Profile not found for this bid."
    end
  end

  def rating_params
    params.require(:rating).permit(:score, :comment)
  end
end