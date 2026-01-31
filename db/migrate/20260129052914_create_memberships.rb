class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.string :name, null: false
      t.integer :price_cents, default: 0
      t.string :billing_interval, default: "monthly"
      t.jsonb :features, default: {}
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
