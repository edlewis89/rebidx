class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  has_one :rating                  # optional, after completion

  enum status: {
    pending: 0,   # Bid submitted, waiting for homeowner
    accepted: 1,  # Optional intermediate, could skip if using awarded
    rejected: 2,
    awarded: 3,   # Homeowner selected this bid
    paid: 4,      # Payment completed
    withdrawn: 5,
    complete: 6
  }

  scope :pending, -> { where(status: :pending) }
  scope :accepted, -> { where(status: :accepted) }
  scope :rejected, -> { where(status: :rejected) }
  scope :awarded, -> { where(status: :awarded) }
  scope :paid, -> { where(status: :paid) }
  scope :withdrawn, -> { where(status: :withdrawn) }
  scope :complete, -> { where(status: :complete) }
  
  validate :only_one_awarded_bid, on: :update
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :message, length: { maximum: 500 }, allow_blank: true
  validates :terms, length: { maximum: 1000 }, allow_blank: true
  validates :status, inclusion: { in: %w[pending awarded rejected withdrawn complete] }

  # validate :handyman_budget_limit
  validate :bid_within_membership_range

  # validates :terms, presence: true
  # Only allow providers to bid once per listing
  validates :user_id,
            uniqueness: {
              scope: :listing_id,
              message: "You have already submitted a bid for this listing. Multiple bids are not allowed."
            }

  # def awarded?
  #   self.status == "awarded"
  # end

  def can_rate?
    status == "complete"
  end

  private

  def handyman_budget_limit
    return unless user&.unlicensed_provider?
    return unless listing

    if listing.budget.to_f >= 1000
      errors.add(:base, "Handymen may only bid on jobs under $1,000")
    end
  end

  def bid_within_membership_range
    return unless user&.membership && listing

    range = user.membership.features["bid_range"] || { "low" => 0, "high" => 1_000 }
    high = range["high"].to_f

    if amount.to_f > high
      errors.add(:amount, "exceeds your max allowed bid of $#{high}")
    end
  end

  def only_one_awarded_bid
    return unless status_changed? && awarded?

    if Bid.where(listing_id: listing_id, status: :awarded).where.not(id: id).exists?
      errors.add(:status, "Only one bid can be awarded per listing")
    end
  end
end
