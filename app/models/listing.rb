class Listing < ApplicationRecord
  attr_accessor :property_title, :property_address

  belongs_to :user
  belongs_to :property, optional: true

  has_many :listing_services, dependent: :destroy
  has_many :services, through: :listing_services
  has_many :bids, dependent: :destroy   # ✅ THIS WAS MISSING
  has_one :awarded_bid, -> { where(status: ["awarded", "in_progress", "complete"]) }, class_name: "Bid"

  enum listing_type: {
    service: 0,
    property_sale: 1,
    build_opportunity: 2,
    investment_opportunity: 3
  }

  enum status: {
    open: 0,
    awarded: 1,
    in_progress: 2,
    complete: 3,
    cancelled: 4,
    expired: 5
  }

  enum deal_type: {
    flip: 0,
    buy_hold: 1,
    wholesale: 2
  }

  validates :title, :description, :budget, presence: true
  validates :budget, numericality: { greater_than: 0 }
  # validate :listing_must_be_open

  scope :open, -> { where(status: "open") }
  scope :complete, -> { where(status: "complete") }


  # Return the bid that was awarded, even if completed
  def winning_bid
    bids.where(status: [:awarded, :paid, :complete])
        .order(updated_at: :desc)
        .first
  end

  def editable?
    open?
  end

  def listing_must_be_open
    errors.add(:listing, "is closed") unless listing.open?
  end

  def can_bid_on?(user)
    return false unless open?

    profile = user.service_provider_profile

    # Handyman / unlicensed
    if profile.nil? || !profile.licensed?
      return budget.to_f <= 1_000
    end

    # Licensed provider
    if budget.to_f <= profile.max_project_budget
      true
    else
      # Above class limit, only verified providers
      profile.verified_provider?
    end
  end

  def nearby_listings
    provider = current_user.service_provider_profile

    radius = current_user.subscription&.membership&.service_radius || 25

    listings = Listing.joins(:property)
                      .merge(Property.near([provider.latitude, provider.longitude], radius))

    render json: listings
  end
end
