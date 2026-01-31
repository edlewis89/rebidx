class AddVerificationFieldsToServiceProviderProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :service_provider_profiles, :full_name, :string
    add_column :service_provider_profiles, :phone_number, :string
    add_column :service_provider_profiles, :tax_id, :string
    add_column :service_provider_profiles, :government_id, :string
    add_column :service_provider_profiles, :business_license_number, :string
  end
end
