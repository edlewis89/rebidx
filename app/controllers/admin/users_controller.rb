module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy] # only actions that need :id

    def index
      @users = User.order(created_at: :desc)
    end

    def show
      # @user is already set by before_action
    end

    def edit
      # @user is already set by before_action
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role)
    end
  end
end