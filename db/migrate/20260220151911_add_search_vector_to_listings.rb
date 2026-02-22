class AddSearchVectorToListings < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :search_vector, :tsvector

    add_index :listings, :search_vector, using: :gin
  end
end

