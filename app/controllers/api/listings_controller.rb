module Api
  class ListingsController < BaseController

    def index
      listings = Listing.all
      render json: listings
    end

    def show
      listing = Listing.find(params[:id])
      render json: listing
    end

    def create
      listing = current_user.listings.build(listing_params)
      if listing.save
        render json: listing, status: :created
      else
        render json: { errors: listing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def nearby
      provider = current_user.service_provider_profile
      return render json: { error: "No provider profile" }, status: :unprocessable_entity unless provider

      radius = current_user.subscription&.membership&.service_radius || 25

      # Efficient DB query joining properties
      property_ids = Property.near([profile.latitude, profile.longitude], radius).pluck(:id)
      listings = Listing.where(property_id: property_ids)

      render json: listings.as_json(
        include: {
          property: { only: [:id, :address, :city, :state, :zipcode] },
          user: { only: [:id, :name, :email] }
        }
      )
    end

    private

    def listing_params
      params.require(:listing).permit(:title, :description, :price)
    end
  end
end