class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update!(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream # will render mark_as_read.turbo_stream.erb
      format.html { redirect_to notifications_path, notice: "Notification marked as read." }
    end
  end
end
