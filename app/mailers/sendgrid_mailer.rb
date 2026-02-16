class SendgridMailer < ApplicationMailer
  default from: 'no-reply@sixhattechnologies.com'

  def confirmation_email(user)
    @user = user
    confirmation_link = "#{ENV['APP_HOST']}/users/confirmation?confirmation_token=#{user.confirmation_token}"

    mail(
      to: @user.email,
      subject: "Confirm your Rebidx account"
    ) do |format|
      format.html { render html: "<p>Click to confirm:</p><a href='#{confirmation_link}'>Confirm Account</a>".html_safe }
    end
  end
end