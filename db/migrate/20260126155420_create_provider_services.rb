class CreateProviderServices < ActiveRecord::Migration[7.1]
  def change
    create_table :provider_services do |t|
      t.references :service_provider_profile, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
