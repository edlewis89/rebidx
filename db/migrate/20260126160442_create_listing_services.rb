class CreateListingServices < ActiveRecord::Migration[7.1]
  def change
    create_table :listing_services do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
