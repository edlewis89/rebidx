class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        ENV['STRIPE_WEBHOOK_SECRET']
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      handle_successful_payment(session)
    end

    head :ok
  end

  private

  def handle_successful_payment(session)
    # TODO: implement payment success logic
    Rails.logger.info "Stripe payment completed: #{session.id}"
  end
end