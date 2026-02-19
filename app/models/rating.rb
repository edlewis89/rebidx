class Rating < ApplicationRecord
  belongs_to :bid
  has_one :profile, through: :bid

  belongs_to :user         # the rater (homeowner)
  delegate :service_provider, to: :bid   # convenience

  validates :bid_id, uniqueness: true
  validates :score, presence: true, inclusion: { in: 1..5 }
  validate :bid_must_be_complete

  scope :active, -> { where(status: [:pending, :accepted, :awarded]) }
  scope :completed, -> { where(status: :complete) }
  scope :open, -> { where(status: :pending) }


  private

  def bid_must_be_complete
    return if bid&.complete?

    errors.add(:bid, "must be complete before rating")
  end
end
