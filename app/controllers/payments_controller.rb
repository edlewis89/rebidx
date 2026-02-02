# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  before_action :authenticate_user!

  # Membership payment checkout
  def create_membership_payment
    membership = Membership.find(params[:membership_id])
    authorize membership, :pay?   # Pundit will now find MembershipPolicy#pay?

    payment = current_user.payments.create!(
      membership: membership,
      amount_cents: membership.price_cents,
      currency: "usd",
      status: :pending
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
                     price_data: {
                       currency: 'usd',
                       product_data: { name: membership.name },
                       unit_amount: membership.price_cents
                     },
                     quantity: 1
                   }],
      mode: 'payment',
      success_url: success_payments_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_payments_url,
      client_reference_id: payment.id
    )

    redirect_to session.url, allow_other_host: true
  end

  # Listing payment checkout (escrow)
  def create_listing_payment
    listing = Listing.find(params[:listing_id])
    authorize listing, :pay?

    payment = current_user.payments.create!(
      listing: listing,
      amount_cents: listing.price_cents,
      currency: "usd",
      status: :pending
    )

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
                     price_data: {
                       currency: 'usd',
                       product_data: { name: "Listing ##{listing.id}" },
                       unit_amount: listing.price_cents
                     },
                     quantity: 1
                   }],
      mode: 'payment',
      success_url: success_payments_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_payments_url,
      client_reference_id: payment.id
    )

    redirect_to session.url, allow_other_host: true
  end

  # Stripe webhook
  skip_before_action :verify_authenticity_token, only: [:webhook]
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET'])
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

  # Success redirect after checkout
  def success
    @payment = Payment.find_by(id: params[:session_id])
    flash[:notice] = "Payment successful!" if @payment
  end

  # Cancel redirect
  def cancel
    flash[:alert] = "Payment canceled."
  end

  private

  def handle_successful_payment(session)
    payment = Payment.find(session.client_reference_id)
    payment.update!(status: :succeeded, stripe_payment_id: session.payment_intent)

    # Activate membership if applicable
    if payment.membership
      payment.user.update!(membership_id: payment.membership.id)
    end

    # For listing payment: hold in escrow or immediately transfer if provider has stripe_account_id
    if payment.listing
      provider = payment.listing.user
      if provider.stripe_account_id.present?
        # Transfer to provider minus platform fee (10% example)
        Stripe::PaymentIntent.create({
                                       amount: (payment.amount_cents * 0.9).to_i,
                                       currency: 'usd',
                                       payment_method_types: ['card'],
                                       transfer_data: { destination: provider.stripe_account_id }
                                     })
      end
    end
  end
end

