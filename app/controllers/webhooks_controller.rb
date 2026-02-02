def stripe
  payload = request.body.read
  sig_header = request.env['HTTP_STRIPE_SIGNATURE']
  event = nil

  begin
    event = Stripe::Webhook.construct_event(
      payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
    )
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    return head :bad_request
  end

  case event.type
  when 'checkout.session.completed'
    session = event.data.object
    handle_successful_payment(session)
  end

  head :ok
end