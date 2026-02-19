class AddLocationToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :address, :string
    add_column :profiles, :city, :string
    add_column :profiles, :state, :string
    add_column :profiles, :zipcode, :string
    add_column :profiles, :latitude, :float
    add_column :profiles, :longitude, :float

    add_index :profiles, [:latitude, :longitude]
  end
end
