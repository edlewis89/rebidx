class CreateRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :ratings do |t|
      t.references :rater, null: false, foreign_key: { to_table: :users }
      t.references :profile, null: false, foreign_key: true
      t.integer :score, null: false
      t.text :review

      t.timestamps
    end
    # Add indexes for faster lookups
    # add_index :ratings, [:rater_id, :profile_id], unique: true  # optional: one rating per user per profile
    # add_index :ratings, :bid_id, unique: true
  end
end
