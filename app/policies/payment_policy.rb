# app/policies/payment_policy.rb
class PaymentPolicy < ApplicationPolicy
  def create_membership_payment?
    user.present?
  end

  def create_listing_payment?
    user.present?
  end

  def success?
    user.present?
  end

  def cancel?
    user.present?
  end
end
