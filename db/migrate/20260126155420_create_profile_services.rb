class CreateProfileServices < ActiveRecord::Migration[7.1]
  def change
    create_table :profile_services do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
