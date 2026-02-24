class CreateLeads < ActiveRecord::Migration[7.1]
  def change
    create_table :leads do |t|
      t.string  :title, null: false
      t.text    :description, null: false
      t.decimal :budget
      t.integer :status, null: false, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :property, foreign_key: true
      t.integer :claimed_by, index: true  # optional provider claiming

      t.timestamps
    end
  end
end
