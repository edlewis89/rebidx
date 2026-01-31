class Notification < ApplicationRecord
  belongs_to :user

  after_create_commit -> {
    broadcast_prepend_to "notifications_#{user.id}"
    broadcast_replace_to "notification_count_#{user.id}",
                         target: "notification_count",
                         partial: "notifications/count",
                         locals: { user: user }
  }

  after_update_commit -> {
    broadcast_replace_to "notifications_count_#{user_id}",
                         target: "notification-count",
                         partial: "notifications/bell_count",
                         locals: { user: user }
  }

  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current)
  end
end
