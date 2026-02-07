class AddVerifiedAtToVerificationProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :verification_profiles, :verified_at, :datetime
  end
end
