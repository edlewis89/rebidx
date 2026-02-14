class AddLocationToServiceProviderProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :service_provider_profiles, :address, :string
    add_column :service_provider_profiles, :city, :string
    add_column :service_provider_profiles, :state, :string
    add_column :service_provider_profiles, :zipcode, :string
    add_column :service_provider_profiles, :latitude, :float
    add_column :service_provider_profiles, :longitude, :float

    add_index :service_provider_profiles, [:latitude, :longitude]
  end
end
