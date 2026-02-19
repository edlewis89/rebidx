# Bid belongs to profile, not user.
# ensure_verified_profile now checks the profile via AccessGate.
# Indexing and associations will follow the profile model, so multiple profiles per user can bid independently.
# Ratings can now attach to the bidding profile.

class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:new, :create]
  before_action :ensure_verified_profile, only: [:new, :create]
  before_action :set_bid, only: [:accept, :reject, :withdrawn, :complete]

  # GET /listings/:listing_id/bids or /bids
  def index
    if params[:listing_id]
      @listing = Listing.find(params[:listing_id])
      @bids = @listing.bids.includes(profile: :user)
    else
      # show all bids from any profile of the current user
      @bids = Bid.joins(:profile)
                 .where(profiles: { user_id: current_user.id })
                 .includes(:listing)
    end
  end

  # GET /listings/:listing_id/bids/new
  def new
    @profiles = current_user.profiles
    @bid = @listing.bids.build
  end

  # POST /listings/:listing_id/bids
  def create
    profile = current_user.profiles.find(params[:profile_id])
    @bid = @listing.bids.build(bid_params.merge(profile: profile))
    authorize @bid

    if @bid.save
      BidNotifier.notify_homeowner(@bid)
      redirect_to after_bid_redirect_path, notice: "Bid submitted successfully."
    else
      flash.now[:alert] = @bid.errors.full_messages.to_sentence
      @profiles = current_user.profiles
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /bids/:id/accept
  def accept
    authorize @bid
    bidder_profile = @bid.profile
    listing_budget = @bid.listing.budget

    # Unlicensed profile rule
    if bidder_profile.unlicensed? && listing_budget > 1_000
      return redirect_to listing_path(@bid.listing),
                         alert: "Unlicensed providers may only be awarded jobs under $1,000."
    end

    # Licensed profile must be verified for high-value jobs
    if bidder_profile.requires_verification? && listing_budget > 1_000 && !bidder_profile.verified?
      return redirect_to listing_path(@bid.listing),
                         alert: "This provider must be verified for high-value jobs."
    end

    ActiveRecord::Base.transaction do
      @bid.update!(status: :awarded)
      @bid.listing.update!(status: :awarded)
      @bid.listing.bids.where.not(id: @bid.id).update_all(status: :rejected)
      BidNotifier.notify_provider_bid_accepted(@bid)
    end

    redirect_to listing_path(@bid.listing),
                notice: "Bid accepted. Provider has been notified."
  end

  # PATCH /bids/:id/reject
  def reject
    authorize @bid

    @bid.update!(status: :rejected)
    BidNotifier.notify_provider_bid_rejected(@bid)
    redirect_to listing_path(@bid.listing), notice: "Bid rejected."
  end

  # PATCH /bids/:id/withdrawn
  def withdrawn
    authorize @bid

    @bid.update!(status: :withdrawn)
    BidNotifier.notify_homeowner_bid_withdrawn(@bid)
    redirect_to provider_dashboard_path, notice: "Bid withdrawn."
  end

  # PATCH /bids/:id/complete
  def complete
    unless @bid.awarded? && @bid.listing.user == current_user
      return redirect_to homeowner_dashboard_path, alert: "You cannot complete this job."
    end

    ActiveRecord::Base.transaction do
      @bid.update!(status: :complete)
      @bid.listing.update!(status: :complete)
    end

    redirect_to homeowner_dashboard_path, notice: "Job marked complete. Please rate the provider."
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def set_bid
    if params[:admin_override]
      @bid = Bid.find(params[:id])
    else
      # only bids on listings of current user
      @bid = Bid.joins(:listing)
                .where(listings: { user_id: current_user.id })
                .find(params[:id])
    end
  end

  def bid_params
    params.require(:bid).permit(:amount, :message, :terms)
  end

  def ensure_verified_profile
    return unless current_user.profiles.any?

    profile = current_user.profiles.find(params[:profile_id])
    gate = AccessGate.new(profile) # AccessGate can take a profile instead of user

    unless gate.can_bid_on?(@listing)
      redirect_to provider_dashboard_path,
                  alert: "This profile is not allowed to bid on this listing."
    end
  end

  def after_bid_redirect_path
    # redirect based on type of profile that placed the bid
    if current_user.profiles.any? { |p| p.profile_type_provider? || p.unlicensed? }
      provider_dashboard_path
    elsif current_user.homeowner?
      homeowner_dashboard_path
    else
      listing_path(@listing)
    end
  end
end

# class BidsController < ApplicationController
#   before_action :authenticate_user!
#   before_action :set_listing, only: [:new, :create]
#   # before_action :set_bid, only: [:accept, :reject]
#
#   # Show all bids for a provider or listing
#   def index
#     # @bids = policy_scope(Bid).includes(:listing, :user)
#     #
#     # # Apply filters if needed
#     # @bids = @bids.where(status: params[:status]) if params[:status].present?
#     # @bids = @bids.joins(:listing).where("listings.title ILIKE ?", "%#{params[:query]}%") if params[:query].present?
#
#     @listing = Listing.find(params[:listing_id])
#     @bids = @listing.bids.includes(:user)
#   end
#
#   def new
#     @bid = @listings.bids.build
#     authorize @bid
#   end
#
#   # Place a bid
#   def create
#     @bid = @listings.bids.build(bid_params)
#     #@bid = current_user.bids.build(bid_params.merge(listing: @listing))
#     @bid.user = current_user
#     authorize @bid
#
#     if @bid.save
#       redirect_to listing_path(@listing), notice: "Bid submitted successfully."
#     else
#       render :new
#     end
#   end
#
#   # Accept bid
#   def accept
#     @bid = Bid.find(params[:id])
#     authorize @bid
#
#     ActiveRecord::Base.transaction do
#       @bid.update!(status: :accepted)
#       @bid.listing.bids.where.not(id: @bid.id).update_all(status: :rejected)
#       @bid.update!(status: :awarded)
#     end
#
#     # trigger escrow/payment logic here
#     redirect_to listing_path(@bid.listing), notice: "Bid accepted."
#   end
#
#   # Reject bid
#   def reject
#     @bid = Bid.find(params[:id])
#     authorize @bid
#
#     @bid.update(status: :rejected)
#     redirect_to listing_path(@bid.listing), notice: "Bid rejected."
#   end
#
#   private
#
#   def set_listing
#     @listing = Listing.find(params[:listing_id])
#   end
#
#   # def set_bid
#   #   @bid = Bid.find(params[:id])
#   # end
#
#   def bid_params
#     params.require(:bid).permit(:amount, :message)
#   end
# end
