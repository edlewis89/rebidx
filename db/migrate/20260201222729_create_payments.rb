class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.references :listing, null: true, foreign_key: true
      t.integer :amount_cents
      t.string :currency
      t.string :stripe_payment_id
      t.string :status

      t.timestamps
    end
  end
end
