# app/controllers/api/properties_controller.rb
module Api
  class PropertiesController < Api::BaseController
    before_action :authenticate_user!
    before_action :ensure_homeowner, only: [:create, :update, :destroy]

    # GET /api/properties
    def index
      properties = current_user.properties
      render json: properties
    end

    # POST /api/properties
    def create
      property = current_user.properties.build(property_params)

      if property.save
        notify_matching_providers(property)
        render json: property, status: :created
      else
        render json: { errors: property.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/properties/:id
    def update
      property = current_user.properties.find(params[:id])
      if property.update(property_params)
        render json: property
      else
        render json: { errors: property.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/properties/:id
    def destroy
      property = current_user.properties.find(params[:id])
      property.destroy
      render json: { message: "Property deleted" }
    end

    # POST /api/properties/batch_create
    def batch_create
      created = []
      errors = []

      params[:properties].each do |prop_params|
        property = current_user.properties.build(prop_params.permit(
          :title, :address, :city, :state, :zipcode, :latitude, :longitude, :parcel_number, :sqft, :zoning
        ))
        if property.save
          created << property
        else
          errors << { property: prop_params[:title], errors: property.errors.full_messages }
        end
      end

      render json: { created: created, errors: errors }
    end

    private

    def ensure_homeowner
      render json: { error: "Only homeowners can manage properties" }, status: :forbidden unless current_user.homeowner?
    end

    def notify_matching_providers(property)
      providers = Profile.joins(:user)
                                        .where(zipcode: property.zipcode)

      providers.find_each do |provider|
        NotificationMailer
          .new_property_for_provider(provider, property)
          .deliver_later
      end
    end

    def property_params
      params.require(:property).permit(
        :title,
        :address,
        :city,
        :state,
        :zipcode,
        :parcel_number,
        :sqft,
        :zoning,
        :latitude,
        :longitude
      )
    end
  end
end