class Api::ProvidersController < Api::BaseController
  before_action :authenticate_user!

  def nearby
    property = current_user.properties.find_by(id: params[:property_id])
    return render json: { error: "Property not found" }, status: :not_found unless property

    radius = current_user.subscription&.membership&.service_radius || 10

    # Use Geocoder `.near` for efficient DB query
    providers = Profile.near([property.latitude, property.longitude], radius)

    render json: providers.as_json(
      only: [:id, :business_name, :full_name, :address, :city, :state, :zipcode],
      include: {
        user: { only: [:id, :name, :email] }
      }
    )
  end
end