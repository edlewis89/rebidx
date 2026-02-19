class Service < ApplicationRecord
  has_many :profile_services
  has_many :profiles, through: :profile_services

  has_many :listing_services
  has_many :listings, through: :listing_services

  validates :name, presence: true
end
