class CreateServiceProviderProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :service_provider_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.boolean :verified, null: false, default: false

      t.timestamps
    end
  end
end
