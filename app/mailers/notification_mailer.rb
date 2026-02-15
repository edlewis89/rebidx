class NotificationMailer < ApplicationMailer
  default from: 'no-reply@sixhattechnologies.com'

  # Homeowner posted a property → notify providers
  def new_property_for_provider(provider, property)
    @provider = provider
    @property = property

    mail(
      to: @provider.user.email,
      subject: "New property in your area"
    )
  end

  # Provider matched → notify homeowner
  def provider_matched(homeowner, provider, property)
    @homeowner = homeowner
    @provider = provider
    @property = property

    mail(
      to: @homeowner.user.email,
      subject: "A provider matched your property"
    )
  end
end
