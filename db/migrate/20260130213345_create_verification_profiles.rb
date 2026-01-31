class CreateVerificationProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :verification_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.integer :trust_score
      t.jsonb :metadata

      t.timestamps
    end
  end
end
