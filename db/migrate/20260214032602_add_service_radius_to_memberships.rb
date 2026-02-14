class AddServiceRadiusToMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :memberships, :service_radius, :integer, default: 25, null: false
  end
end
