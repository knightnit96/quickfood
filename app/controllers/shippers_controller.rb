class ShippersController < ApplicationController
  before_action :load_list_parent_provinces
  before_action :load_categories
  before_action :find_shipper, only: %i(update destroy update_location)

  authorize_resource

  def new
    @shipper = Shipper.new
  end

  def create
    @shipper = Shipper.new shipper_params
    @shipper.user_id = current_user.id
    Shipper.transaction do
      @shipper.save!
      flash[:success] = t "flash.create.success.shipper"
      redirect_to new_shipper_path
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t "flash.create.fail.shipper"
    render :new
  end

  def update
    Shipper.transaction do
      @shipper.update_attributes! shipper_params
      flash[:success] = t "flash.update.success.shipper"
      redirect_to profiles_path(nav: "manage_shipper")
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t "flash.update.fail.shipper"
    redirect_to profiles_path(nav: "manage_shipper")
  end

  def destroy
    if @shipper.destroy
      flash[:success] = t "flash.delete.success.shipper"
    else
      flash[:error] = t "flash.delete.fail.shipper"
    end
    redirect_to profiles_path
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  def update_location
    @shipper.update_attributes(status: params[:value],
      latitude: params[:latitude], longitude: params[:longitude])
    @orders = Order.by_shipper(@shipper.id).by_status([2, 3])
    if @orders.present?
      @orders.each do |order|
        ActionCable.server.broadcast "chat_with_user_#{@shipper.user_id}_channel",
          content: :update_location,
          latitude: @shipper.latitude,
          longitude: @shipper.longitude,
          order_id: order.id
        ActionCable.server.broadcast "chat_with_user_#{order.user_id}_channel",
          content: :update_location,
          latitude: @shipper.latitude,
          longitude: @shipper.longitude,
          order_id: order.id
      end
    end
    if @shipper.status == 1
      cookies.permanent[:shipper] = @shipper.status
    else
      cookies.delete :shipper
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/LineLength

  private

  def shipper_params
    params.require(:shipper).permit :province_id, :identity_card
  end

  def find_shipper
    @shipper = Shipper.find_by id: params[:id]
    return if @shipper
    flash.now[:danger] = t "flash.not_found.shipper"
    redirect_to profiles_path(nav: "manage_shipper")
  end
end
