class CreateListings < ActiveRecord::Migration[7.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :listing_type
      t.string :status
      t.decimal :budget

      t.timestamps
    end
  end
end
