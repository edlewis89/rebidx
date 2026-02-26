# 🔹 How workflow looks now
#
# Bid lifecycle (RebidX):
#
#  pending        # user submitted
# shortlisted    # homeowner marks promising
# accepted       # homeowner awards / winner
# rejected       # explicitly rejected
# withdrawn      # bidder pulls out
#
# Listing workflow:
#
#  open → awarded/in_progress → complete → expired/cancelled
#
# They now match logically — you won’t have conflicts between bid and listing states.

class Bid < ApplicationRecord
  belongs_to :profile
  belongs_to :listing, counter_cache: true
  has_one :rating, -> { where.not(id: nil) }, dependent: :destroy

  # 🔥 gives you bid.user without storing user_id
  has_one :user, through: :profile

  after_commit :update_listing_lowest_bid
  after_destroy :update_listing_lowest_bid

  # =========================
  # ENUMS
  # =========================
  # enum status: {
  #   pending: 0,       # submitted, awaiting review
  #   shortlisted: 1,   # homeowner marked as promising
  #   accepted: 2,      # bid awarded / winner
  #   rejected: 3,      # explicitly rejected
  #   withdrawn: 4      # bidder pulled out
  # }
  enum status: {
    pending: 0,
    accepted: 1,
    rejected: 2,
    withdrawn: 3
  }

  # =========================
  # VALIDATIONS
  # =========================
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :message, length: { maximum: 500 }, allow_blank: true
  validates :terms, length: { maximum: 1000 }, allow_blank: true

  validates :profile_id,
            uniqueness: { scope: :listing_id, message: "You have already submitted a bid for this listing." }

  validate :bid_within_membership_range
  validate :only_one_awarded_bid, on: :update

  # =========================
  # SCOPES
  # =========================
  scope :for_user, ->(user_id) { joins(:profile).where(profiles: { user_id: user_id }) }
  scope :on_user_listings, ->(user_id) { joins(:listing).where(listings: { user_id: user_id }) }

  scope :pending, -> { where(status: :pending) }
  scope :shortlisted, -> { where(status: :shortlisted) }
  scope :accepted, -> { where(status: :accepted) }
  scope :rejected, -> { where(status: :rejected) }
  scope :withdrawn, -> { where(status: :withdrawn) }
  scope :complete, -> { where(status: :accepted).where.not(completed_at: nil) }
  # =========================
  # HELPERS
  # =========================
  def user
    profile.user
  end

  def can_rate?
    accepted? || listing.complete?
  end

  def user_membership
    user.subscription&.membership
  end

  private

  # Make sure bid is allowed for user's membership tier
  def bid_within_membership_range
    return unless user_membership && listing

    range = user_membership.features["bid_range"] || { "low" => 0, "high" => 1_000 }
    high = range["high"].to_f

    if amount.to_f > high
      errors.add(:amount, "exceeds your max allowed bid of $#{high}")
    end
  end

  # Only one awarded bid per listing
  def only_one_awarded_bid
    return unless saved_change_to_status? && accepted?

    if Bid.where(listing_id: listing_id, status: :accepted).where.not(id: id).exists?
      errors.add(:status, "Only one bid can be awarded per listing")
    end
  end

  # Update lowest bid on listing (for display / auto-selection)
  def update_listing_lowest_bid
    listing.update_lowest_bid! if listing
  end
end

