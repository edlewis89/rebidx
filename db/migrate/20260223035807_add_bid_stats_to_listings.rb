class AddBidStatsToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :bid_count, :integer, default: 0, null: false
    add_column :listings, :lowest_bid, :decimal, precision: 12, scale: 2

    add_index :listings, :bid_count
    add_index :listings, :lowest_bid
  end
end
