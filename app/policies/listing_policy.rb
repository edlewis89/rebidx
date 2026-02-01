class ListingPolicy < ApplicationPolicy
  # Only allow signed-in users to create, respecting membership limits
  def new?
    create?  # new is allowed if create is allowed
  end

  # Viewing/editing existing listings is allowed for the owner
  def show?
    record.user == user
  end

  def create?
    binding.pry
    return false unless user.present?
    AccessGate.new(user).can_create_listing?
  end

  def edit?
    record.user == user
  end

  # Only the owner can update
  def update?
    record.user == user
  end

  # Only the owner can destroy
  def destroy?
    record.user == user
  end

  # Only the owner can accept a bid, and listing must be open
  def accept_bid?
    record.user == user && record.status == "open"
  end

  # Only the owner can reject a bid, and listing must be open
  def reject_bid?
    record.user == user && record.status == "open"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Example: users only see their own listings
      scope.where(user: user)
    end
  end
end

