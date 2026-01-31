# app/controllers/admin/listings_controller.rb
module Admin
  class ListingsController < BaseController
    before_action :set_listing, only: [:show, :edit, :update, :destroy]

    def index
      @listings = Listing.includes(:user, :services).order(created_at: :desc)
    end

    def show
      @bids = @listing.bids.includes(:user)
    end

    def edit
      load_services
    end

    def update
      if @listing.update(listing_params)
        redirect_to admin_listing_path(@listing), notice: "Listing updated successfully."
      else
        load_services
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @listing.destroy
      redirect_to admin_listings_path, notice: "Listing deleted"
    end

    private

    def set_listing
      @listing = Listing.find(params[:id])
    end

    def load_services
      @services = Service.order(:name)
    end

    def listing_params
      params.require(:listing).permit(
        :title,
        :description,
        :budget,
        :listing_type,
        :status,
        service_ids: []
      )
    end
  end
end