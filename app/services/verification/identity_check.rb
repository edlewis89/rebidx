module Verification
  class IdentityCheck
    def self.call(profile, payload)
      passed = payload[:confidence_score] > 0.85

      profile.verification_checks.create!(
        kind: "identity",
        provider: "manual_review",
        status: passed ? "passed" : "failed",
        data: payload,
        verified_at: Time.current
      )

      profile.update_status!
    end
  end
end