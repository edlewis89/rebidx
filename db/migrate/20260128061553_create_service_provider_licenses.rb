class CreateServiceProviderLicenses < ActiveRecord::Migration[7.1]
  def change
    create_table :service_provider_licenses do |t|
      t.references :service_provider_profile, null: false, foreign_key: true
      t.references :license_type, null: false, foreign_key: true
      t.string :license_number
      t.string :state
      t.date :expires_on

      t.timestamps
    end
  end
end
