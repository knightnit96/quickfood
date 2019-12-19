class Admin::PlacesController < Admin::ApplicationController
  before_action :find_place, except: %i(index)
  before_action :check_active

  authorize_resource

  def index
    @places = Place.by_is_proposal.by_date
  end

  def destroy
    if @place.destroy
      flash[:success] = t "flash.delete.success.admin_place"
    else
      flash[:danger] = t "flash.delete.fail.admin_place"
    end
    redirect_to admin_places_path
  end

  def change_lock_status
    if params[:value] == "1"
      @place.update_attributes activated: true
    else
      @place.update_attributes activated: false
    end
  end

  def confirm_proposal
    if params[:value] == "1"
      if @place.destroy
        flash[:success] = t "flash.delete.success.admin_place"
      else
        flash[:danger] = t "flash.delete.fail.admin_place"
      end
    else
      if @place.update_attributes is_proposal: false
        flash[:success] = t "flash.update.success.admin_place"
      else
        flash[:danger] = t "flash.update.fail.admin_place"
      end
    end
  end

  private

  def find_place
    @place = Place.find_by id: params[:id]
    return if @place
    flash[:danger] = t "flash.not_found.admin_place"
    redirect_to admin_path
  end

  def check_active
    @active = "place"
  end
end
