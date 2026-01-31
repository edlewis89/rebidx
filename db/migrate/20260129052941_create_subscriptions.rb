class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.string :status, default: "active"
      t.datetime :current_period_end
      t.string :stripe_subscription_id

      t.timestamps
    end
  end
end
