class SendConfirmationJob < ApplicationJob
  queue_as :default   # Sidekiq queue name

  def perform(user_id)
    user = User.find(user_id)

    # Make sure user has a confirmation token
    user.generate_confirmation_token! unless user.confirmation_token

    confirmation_link = "#{ENV['APP_HOST']}/users/confirmation?confirmation_token=#{user.confirmation_token}"

    SendgridMailer.send_email(
      to: user.email,
      subject: "Confirm your Rebidx account",
      html: "<p>Click to confirm:</p><a href='#{confirmation_link}'>Confirm Account</a>"
    )
  rescue => e
    Rails.logger.error("SendGrid failed for user #{user.id}: #{e.message}")
  end
end