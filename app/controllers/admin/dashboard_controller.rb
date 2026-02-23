module Admin
  class DashboardController < BaseController
    def index
      # Verification system metrics
      @total_verification_profiles = VerificationProfile.count
      @verified_users = VerificationProfile.verified.count
      @pending_verifications = VerificationProfile.pending.count
      @rejected_verifications = VerificationProfile.rejected.count
      @unverified_users = VerificationProfile.unverified.count

      # Trust score analytics
      @average_trust_score = VerificationProfile.average(:trust_score)&.round(2) || 0
      @high_trust_users = VerificationProfile.where("trust_score >= ?", 70).count

      # Verification checks insight
      @total_checks = VerificationCheck.count
      @passed_checks = VerificationCheck.passed.count
      @failed_checks = VerificationCheck.failed.count

      # Provider population count (NOT verification-based)
      @total_providers = Profile.count
    end

    private

  end
end