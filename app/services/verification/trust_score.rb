module Verification
  class TrustScore
    WEIGHTS = {
      email: 10,
      phone: 15,
      identity: 30,
      business_license: 25,
      address: 10,
      reviews: 10
    }

    def self.calculate(profile)
      score = profile.verification_checks.passed.sum do |check|
        WEIGHTS[check.kind.to_sym] || 0
      end

      profile.update!(trust_score: score)
      score
    end
  end
end
