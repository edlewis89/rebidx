class BidPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def create?
    can_bid?
  end

  def update?
    user == record.listing.user || user == record.user
  end

  def show?
    user == record.listing.user || user == record.user
  end

  def new?
    create? # reuse same logic
  end

  def accept?
    user.present? && record.listing.user == user && record.pending?
  end

  def reject?
    user.present? && record.listing.user == user && record.pending?
  end

  def can_bid?
    AccessGate.new(user).can_bid_on?(record.listing)
  end

  class Scope < Scope
    def resolve
      if user.service_provider? || user.unlicensed_provider?
        # Providers only see the bids **they have made**
        scope.where(user: user)
      elsif user.homeowner?
        # Homeowners see all bids on their own listings
        scope.joins(:listing).where(listings: { user_id: user.id })
      else
        # Admins / other roles can see everything
        scope.all
      end
    end
  end
end
