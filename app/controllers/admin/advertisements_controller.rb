module Admin
  class AdvertisementsController < BaseController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_advertisement, only: [:edit, :update, :destroy]

  # GET /admin/advertisements/:id
  def show
    @advertisement = Advertisement.find(params[:id])
  end

  # GET /admin/advertisements
  def index
    @advertisements = Advertisement.order(created_at: :desc)
  end

  # GET /admin/advertisements/new
  def new
    @advertisement = Advertisement.new
  end

  # GET /admin/advertisements/:id/edit
  def edit
  end

  # POST /admin/advertisements
  def create
    @advertisement = Advertisement.new(advertisement_params)

    if @advertisement.save
      redirect_to admin_advertisements_path, notice: "Advertisement created successfully."
    else
      flash.now[:alert] = @advertisement.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/advertisements/:id
  def update
    if @advertisement.update(advertisement_params)
      redirect_to admin_advertisements_path, notice: "Advertisement updated successfully."
    else
      flash.now[:alert] = @advertisement.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/advertisements/:id
  def destroy
    @advertisement.destroy
    redirect_to admin_advertisements_path, notice: "Advertisement deleted successfully."
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user.admin?
  end

  def set_advertisement
    @advertisement = Advertisement.find(params[:id])
  end

  def advertisement_params
    params.require(:advertisement).permit(
      :title,
      :placement,
      :image,
      :link,
      :active
    )
  end
  end
end