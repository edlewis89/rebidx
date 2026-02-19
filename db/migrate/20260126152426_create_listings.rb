class CreateListings < ActiveRecord::Migration[7.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :listing_type
      t.integer :status, default: 0, null: false
      t.decimal :budget
      t.integer :asking_price
      t.integer :arv
      t.integer :estimated_rehab
      t.integer :estimated_rent
      t.integer  :deal_type          # wholesale, flip, rental
      t.string  :property_condition # turnkey, light_rehab, heavy_rehab
      t.integer :max_purchase_price

      t.timestamps
    end
    add_index :listings, :status
    add_index :listings, :deal_type
    add_index :listings, [:listing_type, :deal_type]
    add_index :listings, :asking_price
    add_index :listings, :arv
  end
end
