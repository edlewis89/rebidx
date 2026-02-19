class Bid < ApplicationRecord
  belongs_to :profile
  belongs_to :listing
  has_one :rating, -> { where.not(id: nil) }, dependent: :destroy

  # 🔥 gives you bid.user without storing user_id
  has_one :user, through: :profile

  enum status: {
    pending: 0,
    accepted: 1,
    rejected: 2,
    awarded: 3,
    paid: 4,
    withdrawn: 5,
    complete: 6
  }

  # =========================
  # VALIDATIONS
  # =========================

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :message, length: { maximum: 500 }, allow_blank: true
  validates :terms, length: { maximum: 1000 }, allow_blank: true

  # ✅ one bid per profile per listing
  validates :profile_id,
            uniqueness: {
              scope: :listing_id,
              message: "You have already submitted a bid for this listing."
            }

  validate :bid_within_membership_range
  validate :only_one_awarded_bid, on: :update

  # =========================
  # HELPERS
  # =========================

  def can_rate?
    complete?
  end

  private

  def bid_within_membership_range
    membership = profile&.user&.subscription&.membership
    return unless membership && listing

    range = membership.features["bid_range"] || { "low" => 0, "high" => 1_000 }
    high = range["high"].to_f

    if amount.to_f > high
      errors.add(:amount, "exceeds your max allowed bid of $#{high}")
    end
  end

  def only_one_awarded_bid
    return unless saved_change_to_status? && awarded?

    if Bid.where(listing_id: listing_id, status: :awarded)
          .where.not(id: id)
          .exists?
      errors.add(:status, "Only one bid can be awarded per listing")
    end
  end
end

