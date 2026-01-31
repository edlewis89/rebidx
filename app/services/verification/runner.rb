module Verification
  class Runner
    def initialize(user)
      @profile = user.verification_profile || user.create_verification_profile
    end

    def run(kind)
      case kind.to_sym
      when :email
        EmailCheck.call(@profile)
      when :phone
        PhoneCheck.call(@profile)
      when :identity
        IdentityCheck.call(@profile)
      end
    end
  end
end