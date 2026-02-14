class AddCoordinatesToProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :properties, :latitude, :float
    add_column :properties, :longitude, :float

    add_index :properties, [:latitude, :longitude]
  end
end
