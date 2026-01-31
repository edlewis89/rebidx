class VerificationCheck < ApplicationRecord
  belongs_to :verification_profile
  after_save :refresh_profile_status

  enum status: {
    pending: "pending",
    passed: "passed",
    failed: "failed",
    expired: "expired"
  }
  def refresh_profile_status
    verification_profile.update_status!
  end
end