class ProfilesController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  # rubocop:disable Metrics/PerceivedComplexity
  before_action :load_addresses, :load_places, :load_place_vs_menu, :find_user, only: :index
  before_action :find_address, only: %i(update_address delete_address)
  before_action :find_menu_category, only: %i(update_menu_category delete_menu_category)
  before_action :find_menu_item, only: %i(update_menu_item delete_menu_item)
  before_action :find_menu_option, only: %i(update_menu_option delete_menu_option)
  before_action :load_list_parent_provinces
  before_action :load_parent_classify_categories
  before_action :load_categories

  authorize_resource class: false

  def index
    @address = Address.new
    @shipper = Shipper.find_by(user_id: current_user.id, activated: true) if current_user.present?
    @orders = Order.by_user(current_user.id).by_date.page(params[:page]) if current_user.present?
    @orders_shipper = Order.by_shipper(@shipper.id).by_date.page(params[:page]) if current_user.present? && @shipper.present?
  end

  def create_user
    @user = User.new name: params[:name], email: params[:email], password: params[:password],
      password_confirmation: params[:password_confirmation], gender: params[:gender]
    if @user.save
      @address = Address.new name: params[:name], address: params[:address], phone: params[:phone],
        user_id: @user.id, latitude: params[:latitude], longitude: params[:longitude]
      @address.save
      current_user = @user
      o = [(0..9), ("A".."Z")].map(&:to_a).flatten
      unlock_code = (0...10).map{o[rand(o.length)]}.join
      session["unlock_code_" + current_user.id.to_s] = unlock_code
      UnlockUserMailer.unlock_user(current_user, unlock_code).deliver_now if current_user.present?
      render json: {status: :success}
    else
      total_error = t("shared.error_messages.form_error", count: @user.errors.size + @address.errors.size)
      detail_error = @user.errors.full_messages.join(",")
      detail_error += @address.errors.full_messages.join(",")
      render json: {status: :error, errors: total_error + "," + detail_error}
    end
  end

  def confirm_unlock
    if params[:code].upcase == session["unlock_code_" + current_user.id.to_s]
      current_user.update_attributes confirm: true
      render json: {status: :success}
    else
      render json: {status: :error, error: "Mã xác nhận không đúng!"}
    end
  end

  def update_basic_info
    @user = User.find_by id: current_user.id
    if @user.update_attributes user_params_basic_info
      flash[:success] = t "flash.update.success.basic_info"
      redirect_to profiles_path(nav: "basic_info")
    else
      flash.now[:error] = t "flash.update.fail.basic_info"
      render :index
    end
  end

  def update_password
    @user = User.find_by id: current_user.id
    if @user.update_with_password(user_params)
      bypass_sign_in(@user)
      flash[:success] = t "flash.update.success.change_password"
    else
      total_error = t("shared.error_messages.form_error",
        count: @user.errors.size)
      detail_error = @user.errors.full_messages.join(", ")
      flash[:error] = total_error + detail_error
    end
    redirect_to profiles_path(nav: "change_password")
  end

  # rubocop:disable Metrics/BlockNesting
  # rubocop:disable Style/IfInsideElse
  def update_avatar
    if params[:file].present?
      if current_user.avatar.present?
        old_avatar_name = current_user.avatar.file.filename
        if current_user.update_attributes avatar: params[:file]
          add_old = true
          current_user.old_avatar.split(";").each do |ava|
            add_old = false if current_user.avatar.file.filename == ava
          end
          old_avatar = current_user.old_avatar + current_user.avatar.file.filename + ";"
          current_user.update_attributes old_avatar: old_avatar if add_old == true
          avatar = current_user.avatar_url
          render json: {status: :success, message: t("flash.update.success.avatar"), avatar: avatar, old_avatar: old_avatar_name, id: current_user.id}
        else
          render json: {status: :error, message: t("flash.update.fail.avatar")}
        end
      else
        if current_user.update_attributes avatar: params[:file]
          old_avatar = current_user.avatar.file.filename + ";"
          current_user.update_attributes old_avatar: old_avatar
          avatar = current_user.avatar_url
          render json: {status: :success, message: t("flash.update.success.avatar"), avatar: avatar, id: current_user.id}
        else
          render json: {status: :error, message: t("flash.update.fail.avatar")}
        end
      end
    else
      if current_user.update_columns avatar: params[:new_avatar]
        render json: {status: :success}
      else
        render json: {status: :error}
      end
    end
  end
  # rubocop:enable Metrics/BlockNesting
  # rubocop:enable Style/IfInsideElse

  def create_address
    object_create_addresss
    if @address.save
      flash[:success] = t "flash.create.success.address_manage"
    else
      total_error = t("shared.error_messages.form_error",
        count: @address.errors.size)
      detail_error = @address.errors.full_messages.join(", ")
      flash[:error] = total_error + detail_error
    end
    redirect_to profiles_path(nav: "address_manage")
  end

  def update_address
    all_address_params = address_params.merge(
      longitude: params["longitude_address_edit_" + @address.id.to_s],
      latitude: params["latitude_address_edit_" + @address.id.to_s]
    )
    if @address.update_attributes all_address_params
      flash[:success] = t "flash.update.success.address_manage"
    else
      flash[:error] = t "flash.update.fail.address_manage"
    end
    redirect_to profiles_path(nav: "address_manage")
  end

  def delete_address
    if @address.destroy
      flash[:success] = t "flash.delete.success.address_manage"
    else
      flash[:error] = t "flash.delete.fail.address_manage"
    end
    redirect_to profiles_path(nav: "address_manage")
  end

  def create_menu_category
    @food = Food.new name: params[:name], place_id: params[:place_id]
    if @food.save
      flash[:success] = t "flash.create.success.menu_category"
    else
      flash[:error] = t "flash.create.fail.menu_category"
    end
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def create_menu_item
    @food = Food.new name: params[:name], place_id: params[:place_id], price: params[:price],
      discount: params[:discount], image: params[:file], parent_id: params[:food_parent]
    if @food.save
      @foods = Food.by_place(params[:place_id]).is_not_option.child_only
      total_price = 0
      @foods.each do |food|
        total_price += food.price
      end
      average_price = (total_price / @foods.count).to_f
      @place = Place.find_by id: params[:place_id]
      @place.update_attributes average_price: average_price
      render json: {status: :success, message: t("flash.create.success.menu_item")}
    else
      render json: {status: :error, message: t("flash.create.fail.menu_item")}
    end
  end

  def create_menu_option
    Food.transaction do
      params[:list_foods].split(",").map(&:to_i).each do |food|
        1.upto(params[:number].to_i) do |number|
          @food = Food.new name: params["name_" + number.to_s],
            price: params["price_" + number.to_s], parent_id: food,
            place_id: params[:place_id], is_optional: params["option_item_" + number.to_s]
          @food.save!
        end
      end
      flash[:success] = t "flash.create.success.menu_option"
      redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t "flash.create.fail.menu_option"
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def delete_menu_category
    if @menu_category.destroy
      flash[:success] = t "flash.delete.success.menu_category"
    else
      flash[:error] = t "flash.delete.fail.menu_category"
    end
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def delete_menu_item
    if @menu_item.destroy
      @foods = Food.by_place(@menu_item.place_id).is_not_option.child_only
      total_price = 0
      @foods.each do |food|
        total_price += food.price
      end
      average_price = (total_price / @foods.count).to_f
      @place = Place.find_by id: @menu_item.place_id
      @place.update_attributes average_price: average_price
      flash[:success] = t "flash.delete.success.menu_item"
    else
      flash[:error] = t "flash.delete.fail.menu_item"
    end
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def delete_menu_option
    if @menu_option.destroy
      flash[:success] = t "flash.delete.success.menu_option"
    else
      flash[:error] = t "flash.delete.fail.menu_option"
    end
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def update_menu_category
    if @menu_category.update_attributes name: params[:name]
      flash[:success] = t "flash.update.success.menu_category"
    else
      flash[:error] = t "flash.update.fail.menu_category"
    end
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def update_menu_item
    if @menu_item.update_attributes(name: params[:menu_item_name],
      price: params[:menu_item_price], discount: params[:menu_item_discount],
      image: params[:file])
      @foods = Food.by_place(@menu_item.place_id).is_not_option.child_only
      total_price = 0
      @foods.each do |food|
        total_price += food.price
      end
      average_price = (total_price / @foods.count).to_f
      @place = Place.find_by id: @menu_item.place_id
      @place.update_attributes average_price: average_price
      render json: {status: :success, message: t("flash.update.success.menu_item")}
    else
      render json: {status: :error, message: t("flash.update.fail.menu_item")}
    end
  end

  def update_menu_option
    if @menu_option.update_attributes name: params[:menu_option_name],
      price: params[:menu_option_price]
      flash[:success] = t "flash.update.success.menu_option"
    else
      flash[:error] = t "flash.update.fail.menu_option"
    end
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  private

  def user_params_basic_info
    params.require(:user).permit :name, :email, :gender
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def address_params
    params.require(:address).permit :common_name, :name, :address, :phone
  end

  def find_user
    @user = User.find_by id: current_user.id if current_user.present?
  end

  def object_create_addresss
    @address = Address.new address_params
    @address.user_id = current_user.id
    @address.longitude = params[:longitude_address]
    @address.latitude = params[:latitude_address]
  end

  def load_addresses
    @addresses = Address.of_current_user(current_user.id).page(params[:page]) if current_user.present?
  end

  def load_places
    @places = Place.of_current_user current_user.id if current_user.present?
  end

  # rubocop:disable Style/GuardClause
  def load_place_vs_menu
    if params[:tab] == "manage_place" && params[:nav].present?
      param_nav = params[:nav].split("_")
      @place = Place.find_by id: param_nav[2]
      @orders_in_place = Order.by_place(@place.id).by_date.page(params[:page])
      @menu = Food.by_place param_nav[2]
      @menu_cat = Food.by_place(param_nav[2]).parent_only nil
      @menu_food = Food.by_place(param_nav[2]).child_only.is_not_option
      @list_classify_category = []
      ClassifyPlace.by_place(param_nav[2]).each do |cp|
        @list_classify_category << cp.classify_category_id
      end
    end
  end
  # rubocop:enable Style/GuardClause

  def find_address
    @address = Address.find_by id: params[:address_id]
    return if @address
    flash[:danger] = t "flash.not_found.address_manage"
    redirect_to profiles_path(nav: "address_manage")
  end

  def find_menu_category
    @menu_category = Food.find_by id: params[:menu_category_id]
    return if @menu_category
    flash[:danger] = t "flash.not_found.menu_category"
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def find_menu_item
    @menu_item = Food.find_by id: params[:menu_item_id]
    return if @menu_item
    flash[:danger] = t "flash.not_found.menu_item"
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end

  def find_menu_option
    @menu_option = Food.find_by id: params[:menu_option_id]
    return if @menu_option
    flash[:danger] = t "flash.not_found.menu_option"
    redirect_to profiles_path(nav: "manage_place_" + params[:place_id], tab: "manage_place")
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/PerceivedComplexity
end
