class NotificationService
  def self.send(user:, title:, body:, type:, data: {})
    Notification.create!(
      user: user,
      title: title,
      body: body,
      notification_type: type,
      data: data
    )
  end
end