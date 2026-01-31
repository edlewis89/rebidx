module Homeowner
  class ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:edit, :update, :destroy, :show]

  def index
    @listings = current_user.listings.order(created_at: :desc)
  end

  def edit
    load_services
  end

  def update
    if @listing.update(listing_params)
      redirect_to homeowner_listings_path, notice: "Listing updated successfully."
    else
      load_services
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to homeowner_listings_path, notice: "Listing deleted successfully."
  end

  def show
  end

  private

  def set_listing
    @listing = current_user.listings.find(params[:id])
  end

  def load_services
    @services = Service.order(:name)
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :budget, :listing_type, :property_id, service_ids: [])
  end
  end
  end