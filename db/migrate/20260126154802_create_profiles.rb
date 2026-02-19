class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.integer :profile_type
      t.boolean :cash_buyer, default: false
      t.string  :investment_focus   # flip, buy_hold, wholesale
      t.string  :primary_market     # zip/city
      t.boolean :verified, null: false, default: false

      t.timestamps
    end
    add_index :profiles, :profile_type
  end
end
