class CreateLicenseTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :license_types do |t|
      t.string :name
      t.text :description
      t.boolean :requires_verification, null: false, default: true

      t.timestamps
    end
  end
end
