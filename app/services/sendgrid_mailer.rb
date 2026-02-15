require 'sendgrid-ruby'
include SendGrid

class SendgridMailer
  def self.send_email(to:, subject:, html:)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

    from = Email.new(email: 'ed@sixhattechnologies.com')
    to_email = Email.new(email: to)
    content = Content.new(type: 'text/html', value: html)
    mail = Mail.new(from, subject, to_email, content)

    response = sg.client.mail._('send').post(request_body: mail.to_json)

    Rails.logger.info "SendGrid response: #{response.status_code}"
    response
  end
end