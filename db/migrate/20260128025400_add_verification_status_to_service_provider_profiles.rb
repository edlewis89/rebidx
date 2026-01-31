class AddVerificationStatusToServiceProviderProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :service_provider_profiles, :verification_status, :string
    add_index  :service_provider_profiles, :verification_status
  end
end
