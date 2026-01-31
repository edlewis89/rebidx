class Service < ApplicationRecord
  has_many :provider_services
  has_many :service_provider_profiles, through: :provider_services

  has_many :listing_services
  has_many :listings, through: :listing_services

  validates :name, presence: true
end
