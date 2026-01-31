class CreateAdvertisements < ActiveRecord::Migration[7.1]
  def change
    create_table :advertisements do |t|
      t.string :title
      t.string :image
      t.string :url
      t.boolean :active
      t.date :start_date
      t.date :end_date
      t.integer :placement, default: 0, null: false
      t.string :link, default: "", null: true

      t.timestamps
    end
  end
end
