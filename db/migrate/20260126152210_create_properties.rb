class CreateProperties < ActiveRecord::Migration[7.1]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :address
      t.string :city
      t.integer :zipcode
      t.string :parcel_number
      t.integer :sqft
      t.string :zoning

      t.timestamps
    end
  end
end
