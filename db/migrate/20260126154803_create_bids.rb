class CreateBids < ActiveRecord::Migration[7.1]
  def change
    create_table :bids do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.decimal :amount, default: 0
      t.text :message
      t.text :terms
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :bids, [:listing_id, :profile_id], unique: true
  end
end
