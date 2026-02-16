require 'sendgrid-ruby'
include SendGrid

class SendgridMailer
  default from: 'no-reply@sixhattechnologies.com'
  def confirmation_email(user)

    #  resource.generate_confirmation_token! if resource.respond_to?(:generate_confirmation_token!)
    #  resource.save!

    @user = user
    confirmation_link = "#{ENV['APP_HOST']}/users/confirmation?confirmation_token=#{user.confirmation_token}"

    mail(
      to: @user.email,
      subject: "Confirm your Rebidx account"
    ) do |format|
      format.html { render html: "<p>Click to confirm:</p><a href='#{confirmation_link}'>Confirm Account</a>".html_safe }
    end
  end

  def self.send_email(to:, subject:, html:)
    Rails.logger.info "SendGrid::SendEmail >>>> "
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    Rails.logger.info "SendGrid::SendEmail >>>> #{ENV['SENDGRID_API_KEY']}"
    from = Email.new(email: 'ed@sixhattechnologies.com')
    to_email = Email.new(email: to)
    content = Content.new(type: 'text/html', value: html)
    mail = Mail.new(from, subject, to_email, content)
    Rails.logger.info "SendGrid::SendEmail >>>> #{from}"

    Rails.logger.info "SendGrid::SendEmail >>>> Sending confirmation to #{to} via SendGrid"
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    Rails.logger.info "SendGrid::SendEmail >>>> SendGrid response: #{response.status_code} #{response.body}"

    Rails.logger.info "SendGrid::SendEmail >>>> SendGrid response: #{response.status_code}"
    response
  end
end