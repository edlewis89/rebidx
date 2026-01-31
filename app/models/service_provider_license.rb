class ServiceProviderLicense < ApplicationRecord
  belongs_to :service_provider_profile
  belongs_to :license_type
end
