class AddPropertyTypeToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :property_type, :string, null: false
    add_index  :listings, :property_type
  end
end
