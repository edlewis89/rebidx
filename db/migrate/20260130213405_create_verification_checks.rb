class CreateVerificationChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :verification_checks do |t|
      t.references :verification_profile, null: false, foreign_key: true
      t.string :kind
      t.string :status
      t.string :provider
      t.jsonb :data
      t.datetime :verified_at

      t.timestamps
    end
  end
end
