class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :membership, optional: true
  belongs_to :listing, optional: true

  enum status: { pending: "pending", succeeded: "succeeded", failed: "failed" }

  validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
end
