module ApplicationHelper

  def signup_message(user)
    if FeatureFlags.email_verification_enabled?
      "Confirmation email sent to #{user.email}. Please verify your email."
    else
      "Signup successful."
    end
  end

end
