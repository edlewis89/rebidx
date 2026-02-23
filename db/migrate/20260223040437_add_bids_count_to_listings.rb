class AddBidsCountToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :bids_count, :integer, default: 0, null: false
    add_index :listings, :bids_count
  end
end
