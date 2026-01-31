class VerificationProfile < ApplicationRecord
  belongs_to :user
  has_many :verification_checks

  enum status: {
    unverified: "unverified",
    pending: "pending",
    verified: "verified",
    rejected: "rejected"
  }

  # Predicates for convenience
  def unverified?
    status == "unverified"
  end

  def pending?
    status == "pending"
  end

  def verified?
    status == "verified"
  end

  def rejected?
    status == "rejected"
  end

  # Only used if you have a "not_required" state
  def not_required?
    status == "not_required"
  end

  def update_status!
    passed = verification_checks.passed.count
    failed = verification_checks.failed.count

    new_status =
      if passed >= 3
        "verified"
      elsif failed > 0
        "rejected"
      elsif passed > 0
        "pending"
      else
        "unverified"
      end

    update!(status: new_status) if status != new_status

    Verification::TrustScore.calculate(self)
  end
end