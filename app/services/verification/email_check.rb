module Verification
  class EmailCheck
    def self.call(profile)
      check = profile.verification_checks.create!(
        kind: "email",
        status: "passed",
        verified_at: Time.current
      )

      profile.update_status!
      check
    end
  end
end