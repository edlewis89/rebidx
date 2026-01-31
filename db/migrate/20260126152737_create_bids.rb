class CreateBids < ActiveRecord::Migration[7.1]
  def change
    create_table :bids do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.decimal :amount, default: 0
      t.text :message
      t.text :terms
      t.integer :status, default: false

      t.timestamps
    end
  end
end
