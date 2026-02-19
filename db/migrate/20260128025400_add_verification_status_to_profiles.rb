class AddVerificationStatusToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :verification_status, :string
    add_index  :profiles, :verification_status
  end
end
