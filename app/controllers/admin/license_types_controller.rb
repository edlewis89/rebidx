module Admin
  class LicenseTypesController < BaseController
    def index
      @license_types = LicenseType.order(:name)
    end

    def new
      @license_type = LicenseType.new
    end

    def create
      @license_type = LicenseType.new(license_type_params)
      if @license_type.save
        redirect_to admin_license_types_path, notice: "License added"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @license_type = LicenseType.find(params[:id])
    end

    def update
      @license_type = LicenseType.find(params[:id])
      if @license_type.update(license_type_params)
        redirect_to admin_license_types_path, notice: "License updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      LicenseType.find(params[:id]).destroy
      redirect_to admin_license_types_path, notice: "License removed"
    end

    private

    def license_type_params
      params.require(:license_type)
            .permit(:name, :description, :requires_verification)
    end
  end
end