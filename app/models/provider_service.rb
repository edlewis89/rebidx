class ProviderService < ApplicationRecord
  belongs_to :service_provider_profile
  belongs_to :service
end
