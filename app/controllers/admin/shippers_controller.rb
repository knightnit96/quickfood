class Admin::ShippersController < Admin::ApplicationController
  before_action :find_shipper, except: %i(index)
  before_action :check_active

  authorize_resource

  def index
    @shippers = Shipper.all
  end

  def destroy
    if @shipper.destroy
      flash[:success] = t "flash.delete.success.admin_shipper"
    else
      flash[:danger] = t "flash.delete.fail.admin_shipper"
    end
    redirect_to admin_shippers_path
  end

  def change_lock_status
    if params[:value] == "1"
      @shipper.update_attributes activated: true
    else
      @shipper.update_attributes activated: false
    end
  end

  private

  def find_shipper
    @shipper = Shipper.find_by id: params[:id]
    return if @shipper
    flash[:danger] = t "flash.not_found.admin_shipper"
    redirect_to admin_path
  end

  def check_active
    @active = "shipper"
  end
end
