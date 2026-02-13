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

    private

    def listing_params
      params.require(:listing).permit(:title, :description, :price)
    end
  end
end