class MembershipsController < ApplicationController
  def index
    @memberships = Membership.where(active: true)
  end
end