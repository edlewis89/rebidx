class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :bid                  # the completed bid/job
  delegate :service_provider, to: :bid   # convenience
  validates :score, inclusion: { in: 1..5 }
end
