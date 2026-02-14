module Api
  class ListingsController < Api::BaseController

    # GET /api/listings
    def index
      listings = current_user.role == "homeowner" ? current_user.listings : Listing.all
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

    # PATCH /api/listings/:id
    def update
      listing = current_user.listings.find(params[:id])
      if listing.update(listing_params)
        render json: listing
      else
        render json: { errors: listing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/listings/:id
    def destroy
      listing = current_user.listings.find(params[:id])
      listing.destroy
      render json: { message: "Listing deleted" }
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

    def ensure_homeowner
      render json: { error: "Only homeowners can manage listings" }, status: :forbidden unless current_user.homeowner?
    end

    def listing_params
      params.require(:listing).permit(
        :title,
        :description,
        :listing_type,
        :status,
        :budget,
        :property_id,
        service_ids: []
      )
    end
  end
end