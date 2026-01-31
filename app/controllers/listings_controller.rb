class ListingsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_listing, only: %i[show edit update destroy]
  before_action :ensure_no_bids, only: %i[destroy]

  def index
    if current_user&.service_provider?
      profile = current_user.service_provider_profile

      if profile
        @listings = Listing.open.joins(:services)
                           .where(services: { id: profile.service_ids })
                           .distinct

        # Unlicensed providers: only jobs <= $1,000
        if current_user.unlicensed_provider?
          @listings = @listings.where("budget <= ?", 1000)
        end
      else
        @listings = Listing.none
        flash.now[:alert] = "Complete your provider profile to see biddable listings."
      end

    elsif current_user&.homeowner?
      @listings = current_user.listings.includes(:services)
    else
      @listings = Listing.open.includes(:services)
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end

  def new
    @listing = current_user.listings.build
    load_services
    @properties = current_user.properties
    authorize @listing
  end

  def edit
    load_services
  end

  def create
    @listing = current_user.listings.build(listing_params)

    gate = ::MembershipGate.new(current_user)

    unless gate.can_create_listing?
      NotificationService.send(
        user: current_user,
        title: "Listing Limit Reached",
        body: "You’ve reached your membership listing limit. Upgrade to post more listings.",
        type: "membership_limit"
      )

      redirect_to memberships_path, alert: "You have reached your listing limit. Upgrade to post more listings." and return
    end

    authorize @listing

    # Assign property
    if listing_params[:property_id].present?
      @listing.property = current_user.properties.find(listing_params[:property_id])
    elsif listing_params[:property_title].present? && listing_params[:property_address].present?
      @listing.property = current_user.properties.create!(
        title: listing_params[:property_title],
        address: listing_params[:property_address]
      )
    else
      flash.now[:alert] = "You must select a property or enter property details."
      load_services
      render :new, status: :unprocessable_entity and return
    end

    @listing.status = :open

    if @listing.save
      NotificationService.send(
        user: current_user,
        title: "Listing Posted",
        body: "Your listing has been successfully published.",
        type: "listing_created",
        data: { listing_id: @listing.id }
      )
      # Show the newly created listing
      redirect_to homeowner_dashboard_path, notice: "Listing posted successfully."
    else
      load_services
      @properties = current_user.properties
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @listing.update(listing_params)
      redirect_to homeowner_dashboard_path, notice: "Listing updated."
    else
      load_services
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to homeowner_dashboard_path, notice: "Listing removed."
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def load_services
    @services = Service.order(:name)
  end

  def ensure_no_bids
    throw(:abort) if bids.exists?
  end

  def listing_params
    params.require(:listing).permit(
      :title,
      :description,
      :budget,
      :listing_type,
      :property_id,       # for selecting existing property
      :property_title,    # virtual attribute for new property
      :property_address,  # virtual attribute for new property
      service_ids: []
    )
  end
end
