class AddBidToRatings < ActiveRecord::Migration[7.1]
  def change
    add_reference :ratings, :bid, null: false, foreign_key: true
  end
end
