class MembershipsController < ApplicationController
  def index
    @memberships = Membership.where(active: true).order(:price_cents)
    @current_membership = current_user.membership
  end
end