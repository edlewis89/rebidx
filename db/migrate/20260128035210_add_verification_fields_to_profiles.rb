class AddVerificationFieldsToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :full_name, :string
    add_column :profiles, :phone_number, :string
    add_column :profiles, :tax_id, :string
    add_column :profiles, :government_id, :string
    add_column :profiles, :business_license_number, :string
  end
end
