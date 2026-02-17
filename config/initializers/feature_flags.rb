# config/initializers/feature_flags.rb
module FeatureFlags
  def self.email_verification_enabled?
    ENV.fetch("EMAIL_VERIFICATION_ENABLED", "false") == "true"
  end
end