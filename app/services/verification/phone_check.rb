module Verification
  class PhoneCheck
    def self.call(profile, code:)
      stored_code = profile.metadata["sms_code"]

      status = (code == stored_code) ? "passed" : "failed"

      profile.verification_checks.create!(
        kind: "phone",
        status: status,
        verified_at: Time.current
      )

      profile.update_status!
    end
  end
end