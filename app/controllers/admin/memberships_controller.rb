class Admin::MembershipsController < Admin::BaseController
  before_action :set_membership, only: %i[edit update show destroy]

  def index
    @memberships = Membership.where(active: true).order(:price_cents)
    @current_membership = current_user.membership
  end

  def new
    @membership = Membership.new(features: {})
  end

  def create
    @membership = Membership.new(processed_membership_params)
    if @membership.save
      redirect_to admin_memberships_path, notice: "Membership created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @membership.update(processed_membership_params)
      redirect_to admin_memberships_path, notice: "Membership updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
  end

  def destroy
    @membership.destroy
    redirect_to admin_memberships_path, notice: "Membership deleted."
  end

  private

  def set_membership
    @membership = Membership.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(
      :name,
      :price_cents,
      features: [
        :max_listings,
        :max_bids_per_month,
        :messaging,
        :featured_listings,
        :priority_support,
        bid_range: [
          :class_a => [:min, :max],
          :class_b => [:min, :max],
          :class_c => [:min, :max]
        ]
      ]
    )
  end

  # --- Convert price to cents and clean up features hash ---
  def processed_membership_params
    mp = membership_params.dup

    # Convert price from dollars to cents if it's a decimal
    if mp[:price_cents].present?
      mp[:price_cents] = (mp[:price_cents].to_f * 100).to_i
    end

    # Ensure features hash is present
    mp[:features] ||= {}
    mp
  end
end
