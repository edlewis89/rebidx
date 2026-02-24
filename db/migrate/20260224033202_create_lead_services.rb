class CreateLeadServices < ActiveRecord::Migration[7.1]
  def change
    create_table :lead_services do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.timestamps
    end

    add_index :lead_services, [:lead_id, :service_id], unique: true
  end
end
