class Admin::UsersController < Admin::ApplicationController
  before_action :find_user, except: %i(new create index)
  before_action :check_active

  authorize_resource

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @user = User.new user_params
    if @user.save
      @address = Address.new name: @user.name, address: params[:address],
        phone: params[:phone], user_id: @user.id, latitude: params[:latitude],
        longitude: params[:longitude]
      @address.save
      flash[:success] = t "flash.create.success.admin_user"
      redirect_to admin_users_path
    else
      flash.now[:error] = t "flash.create.fail.admin_user"
      render :new
    end
  end
  # rubocop:enable Metrics/AbcSize

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "flash.update.success.admin_user"
      redirect_to admin_users_path
    else
      flash.now[:error] = t "flash.update.fail.admin_user"
      render :edit
    end
  end

  def destroy
    unless @user.id == current_user.id
      if @user.destroy
        flash[:success] = t "flash.delete.success.admin_user"
      else
        flash[:danger] = t "flash.delete.fail.admin_user"
      end
    end
    redirect_to admin_users_path
  end

  def change_lock_status
    if params[:value] == "1"
      @user.lock_access!(send_instructions: false)
    else
      @user.unlock_access!
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password, :gender,
      :password_confirmation, :avatar
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "flash.not_found.admin_user"
    redirect_to admin_path
  end

  def check_active
    @active = "user"
  end
end
