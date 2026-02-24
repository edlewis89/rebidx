class LeadsController < ApplicationController
  def index
    # show all leads for the current user
    @leads = current_user.leads.order(created_at: :desc)
  end

  def show
    @lead = current_user.leads.find(params[:id])
  end

  def new
    @lead = current_user.leads.new
  end

  def create
    @lead = current_user.leads.new(lead_params)
    @lead.status = :started

    if @lead.save
      redirect_to @lead, notice: "Your lead has been created!"
    else
      render :new
    end
  end

  # optional conversion
  def convert_to_listing
    @lead = current_user.leads.find(params[:id])
    # logic to convert lead into a listing
    redirect_to @lead, notice: "Lead converted to listing!"
  end

  private

  def lead_params
    params.require(:lead).permit(:title, :description, :budget, :property_id)
  end
end