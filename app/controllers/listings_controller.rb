# Changes Made:
#
#  Always use profile instead of current_user for listings, properties, and access checks.
#
#  Homeowners and providers now reference their specific profiles.
#
#  AccessGate is initialized with the profile so verification, licensing, and feature checks are profile-specific.
#
#  @listing = profile.listings.build ensures listings are tied to the correct profile.

class ListingsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_listing, only: %i[show edit update destroy]
  before_action :ensure_no_bids, only: %i[destroy]

  # GET /listings
  def index
    Rails.logger.debug "FACET PARAMS: #{params.to_unsafe_h}"
    base_scope =
      if current_user&.profiles&.any?
        profile = current_user.profiles.first
        gate = AccessGate.new(profile)

        if profile.service_provider?
          scope = Listing.open
                         .joins(:services)
                         .where(services: { id: profile.service_ids })
                         .distinct

          # Unlicensed providers: only jobs <= $1,000
          scope = scope.where("budget <= ?", 1_000) unless profile.licensed?

          @my_bids = current_user.bids.includes(:listing)
          @bids_remaining = gate.bids_remaining

          scope

        elsif profile.homeowner?
          profile.listings.includes(:services)

        else
          Listing.open.includes(:services)
        end
      else
        Listing.open.includes(:services)
      end

    # ✅ apply faceted search ON TOP of permission scope
    filtered = base_scope.faceted_search(search_params)

    @listings = filtered.order(created_at: :desc).limit(50)
    @facets   = Listing.facet_counts(filtered)
  end

  # GET /listings/:id
  def show
    # no change; AccessGate can be used in view if needed
  end

  # GET /listings/new
  def new
    profile = current_user.profiles.first
    gate = AccessGate.new(profile)

    unless gate.can_create_listing?
      redirect_to memberships_path,
                  alert: "You have reached your membership listing limit. Upgrade to post more listings."
      return
    end

    @listing = profile.listings.build
    load_services
    @properties = profile.properties
    authorize @listing
  end

  # POST /listings
  def create
    profile = current_user.profiles.first
    gate = AccessGate.new(profile)
    @listing = profile.listings.build(listing_params)
    authorize @listing

    unless gate.can_create_listing?
      NotificationService.send(
        user: current_user,
        title: "Listing Limit Reached",
        body: "You’ve reached your membership listing limit. Upgrade to post more listings.",
        type: "membership_limit"
      )
      redirect_to memberships_path, alert: "You have reached your listing limit. Upgrade to post more listings." and return
    end

    # Assign property
    if listing_params[:property_id].present?
      @listing.property = profile.properties.find(listing_params[:property_id])
    elsif listing_params[:property_title].present? && listing_params[:property_address].present?
      @listing.property = profile.properties.create!(
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
      redirect_to homeowner_dashboard_path, notice: "Listing posted successfully."
    else
      load_services
      @properties = profile.properties
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /listings/:id
  def update
    authorize @listing

    if @listing.update(listing_params)
      redirect_to homeowner_dashboard_path, notice: "Listing updated."
    else
      load_services
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /listings/:id
  def destroy
    authorize @listing
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

  def search_params
    params.permit(
      :q,
      :listing_type,
      :status,
      :min_budget,
      :max_budget,
      :deal_type,
      :property_condition,
      :property_type,
      service_ids: []
    )
  end
end
