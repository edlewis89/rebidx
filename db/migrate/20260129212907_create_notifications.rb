class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.string :notification_type
      t.datetime :read_at
      t.string :url
      t.jsonb :data, default: {}

    t.timestamps
    end
  end
end
