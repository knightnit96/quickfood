class PlacesController < ApplicationController
  before_action :load_list_parent_provinces
  before_action :load_parent_classify_categories
  before_action :load_categories
  before_action :find_place, only: %i(update destroy update_status)
  include ApplicationHelper

  authorize_resource

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/BlockLength
  def index
    province_id = 1
    @provinces.each do |province|
      if province.to_slug_province(province.name) == params[:province]
        province_id = province.id
      end
    end
    @province = Province.find_by id: province_id
    @list_provinces = Province.parent_only(province_id)
    @places_all = Place.is_activated_and_not_proposal.by_province(@list_provinces.pluck(:id))
    @places = Place.is_activated_and_not_proposal.by_province(@list_provinces.pluck(:id))
    @places = Place.is_activated_and_not_proposal.by_province(@list_provinces.pluck(:id)).search_public(params[:keyword]) if params[:keyword].present?
    if current_user.present?
      @addresses = Address.of_current_user current_user.id
      cookies[:address] = @addresses.first.id if cookies[:address].blank?
    end
    @places = @places.by_rating(params[:rating]) if params[:rating].present?
    @places = @places.by_cat(params["checkbox-category"].split(",")) if params["checkbox-category"].present?
    @places = @places.by_province(params["checkbox-district"].split(",")) if params["checkbox-district"].present?
    @places = @places.sort_by_status
  end

  def new
    @place = Place.new
  end

  def create
    object_place_create
    Place.transaction do
      @place.save!
      params[:list_classify_category].split(",").map(&:to_i).each do |cc|
        @place.classify_places.create!(classify_category_id: cc)
      end
      flash[:success] = t "flash.create.success.place"
      redirect_to new_place_path
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t "flash.create.fail.place"
    render :new
  end

  def update
    Place.transaction do
      @place.update_attributes! place_params
      @place.update_attributes! longitude: params[:longitude]
      @place.update_attributes! latitude: params[:latitude]
      @place.classify_places.destroy_all
      params[:list_classify_category].split(",").map(&:to_i).each do |cc|
        @place.classify_places.create!(classify_category_id: cc)
      end
      flash[:success] = t "flash.update.success.place"
      redirect_to profiles_path(nav: "manage_place_" + @place.id.to_s, tab: "manage_place")
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t "flash.update.fail.place"
    redirect_to profiles_path(nav: "manage_place_" + @place.id.to_s, tab: "manage_place")
  end

  def destroy
    if @place.destroy
      flash[:success] = t "flash.delete.success.place"
    else
      flash[:error] = t "flash.delete.fail.place"
    end
    redirect_to profiles_path
  end

  def show
    @place = Place.find_by id: params[:id]
    @menu_categories = Food.by_place(params[:id]).parent_only(nil)
    check_cookie_cart
    @subtotal = get_subtotal_price(@foods)
    @reviews = Rate.place_reviews(params[:id]).by_date
    @classifies = ClassifyPlace.by_place params[:id]
    @classify_no_icon_parent = ClassifyCategory.by_icon("0").parent_only nil
    @classify_icon_parent = ClassifyCategory.by_icon("1").parent_only nil
  end

  def show_province_child
    @province_child = Province.parent_only params[:province_parent_id]
    return unless @province_child
    render json: {province_child: @province_child}
  end

  def add_to_cart
    @food = Food.find_by id: params[:food_id]
    @key_food = params[:food_id]
    if params[:food_option].present?
      @key_food = params[:food_id] + "," + params[:food_option]
    end
    add_food @key_food
    foods_in_cart = check_cookie_cart
    price = @food.price
    price = @food.discount if @food.discount.present?
    price *= foods_in_cart[@key_food].to_i
    @food_options = Hash.new
    params[:food_option].split(",").each do |fo|
      @food_option = Food.find_by id: fo
      price_option = @food_option.price * foods_in_cart[@key_food].to_i
      @food_options[@food_option.name] = fo + "-" + number_to_currency_format(price_option)
    end
    render json: {
      food: @food,
      subtotal: number_to_currency_format(get_subtotal_price(@foods)),
      price: number_to_currency_format(price),
      food_exist: @food_exist,
      quantity: foods_in_cart[@key_food].to_i,
      key_food: @key_food,
      food_option: @food_options,
      id: params[:id]
    }
  end

  def update_cart
    if params[:quantity] == "0"
      delete_food params[:key]
    else
      update_food params[:key], params[:quantity]
    end
    @food = Food.find_by id: params[:key].split(",")[0]
    check_cookie_cart
    price = @food.price
    price = @food.discount if @food.discount.present?
    price *= params[:quantity].to_i
    @food_options = Hash.new
    params[:key].split(",")[1..-1].each do |fo|
      @food_option = Food.find_by id: fo
      price_option = @food_option.price * params[:quantity].to_i
      @food_options[fo] = number_to_currency_format(price_option)
    end
    render json: {
      new_price: number_to_currency_format(price),
      new_subtotal: number_to_currency_format(get_subtotal_price(@foods)),
      new_food_option: @food_options
    }
  end

  def show_order
    @place = Place.find_by id: params[:id]
    @menu_categories = Food.by_place(params[:id]).parent_only(nil)
    check_cookie_cart
    @subtotal = get_subtotal_price(@foods)
    @addresses = Address.of_current_user current_user.id
    @reviews = Rate.place_reviews(params[:id]).by_date
    @classifies = ClassifyPlace.by_place params[:id]
    @classify_no_icon_parent = ClassifyCategory.by_icon("0").parent_only nil
    @classify_icon_parent = ClassifyCategory.by_icon("1").parent_only nil
  end

  def express_checkout
    if params[:payment] == "2"
      response = EXPRESS_GATEWAY.setup_purchase(
        params[:total_price].to_i,
        ip: "192.168.0.34",
        return_url: "http://localhost:3000/places/" + params[:id].to_s + "/show_order?payment=" + params[:payment] + "&address=" + params[:address] + "&fee=" + params[:fee] + "&place_id=" + params[:id].to_s,
        cancel_return_url: "http://localhost:3000/places/" + params[:id].to_s + "/show_order",
        currency: "USD",
        allow_guest_checkout: true,
        items: [{name: "Order in Quickfood", description: "Order in Quickfood", quantity: "1", amount: params[:total_price].to_i}]
      )
      redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    else
      create_order
    end
  end

  def create_order
    check_cookie_cart
    @order = Order.new user_id: current_user.id, place_id: params[:id],
      total_price: get_subtotal_price(@foods), payment: params[:payment],
      address_id: params[:address], fee: params[:fee]
    Order.transaction do
      @order.save
      if params[:payment] == "2"
        total_price = (@order.total_price + @order.fee) * 0.0043
        @order.purchase(total_price, params[:token], params[:payer_id])
      end
      save_product_order @foods
      @place = Place.find_by id: params[:id]
      message = ""
      @foods.each do |key, value|
        message += value.to_s + " x "
        key.split(",").each do |fo_item|
          @food = Food.find_by id: fo_item
          message += if @food.is_optional.zero?
                       @food.name
                     else
                       ", " + @food.name
                     end
        end
        message += ". "
      end
      ActionCable.server.broadcast "notification_order_#{@place.user_id}_channel",
        content: :order_food,
        message: message,
        order_id: @order.id,
        status: 1
      @message = Message.new order_id: @order.id, message: "Đơn hàng đã được tạo. Đang chờ xác nhận..."
      @message.save
      flash[:success] = t "flash.create.success.order"
      redirect_to root_path
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t "flash.create.fail.order"
    redirect_to show_order_place_path(@order)
  end

  def update_order
    @order = Order.find_by id: params[:order_id]
    @order.update_attributes status: params[:status]
    @message = Message.new order_id: @order.id, message: "Đơn hàng đã được xác nhận. Đang tìm tài xế..."
    @message.save
    date_time = l @message.created_at, format: :short
    user_name = "HỆ THỐNG"
    ActionCable.server.broadcast "chat_with_user_#{@order.user_id}_channel",
      content: :order_food,
      message: @message.message,
      order_id: @order.id,
      date_time: date_time,
      user_name: user_name,
      receiver: true
    @place = Place.find_by id: @order.place_id
    @shippers_online = Shipper.by_online
    @shippers_online_near = @shippers_online.near([@place.latitude,
      @place.longitude], 2, units: :km)
    @address = Address.find_by id: @order.address_id
    message = "Có một đơn hàng mới. Nhận tại địa điểm: " + @place.address + ". Giao tại: " + @address.address
    @shippers_online_near.each do |shipper|
      ActionCable.server.broadcast "find_shipper_#{shipper.user_id}_channel",
        content: :order_food,
        message: message,
        order_id: @order.id,
        status: 2
    end
  end

  def find_shipper
    @order = Order.find_by id: params[:order_id]
    had_recipient = false
    if @order.shipper_id.nil?
      @shipper = Shipper.find_by user_id: current_user.id
      @shipper.update_attributes status: 2
      @order.update_attributes status: params[:status], shipper_id: @shipper.id
      @message = Message.new order_id: @order.id, message: "Tài xế  " + current_user.name + " đã tham gia cuộc trò chuyện. Đang trên đường lấy món..."
      @message.save
      date_time = l @message.created_at, format: :short
      user_name = "HỆ THỐNG"
      ActionCable.server.broadcast "chat_with_user_#{@order.user_id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name,
        receiver: true
    else
      had_recipient = true
    end
    render json: {
      had_recipient: had_recipient
    }
  end

  def update_status
    @place.update_attributes status: params[:value]
  end

  def update_status_order_cancel
    status = 1
    @order = Order.find_by id: params[:id]
    if @order.status == 3 || @order.status == 4
      status = 0
    else
      message = "Đơn hàng #" + @order.id.to_s + " đã bị hủy!"
      @message = Message.new order_id: @order.id, message: message
      @message.save
      @place = Place.find_by id: @order.place_id
      if current_user.id != @place.user_id
        ActionCable.server.broadcast "cancel_order_#{@place.user_id}_channel",
          content: :cancel_order,
          message: message,
          reset: false
      else
        status = 2
      end
      if current_user.id != @order.user_id
        ActionCable.server.broadcast "cancel_order_#{@order.user_id}_channel",
          content: :cancel_order,
          message: message,
          reset: true
      end
      if @order.status == 2
        @shipper = Shipper.find_by id: @order.shipper_id
        if current_user.id != @shipper.user_id
          ActionCable.server.broadcast "cancel_order_#{@shipper.user_id}_channel",
            content: :cancel_order,
            message: message,
            reset: true
        end
        @shipper.update_attributes status: 1
      end
      @order.update_attributes status: params[:status]
    end
    render json: {
      status: status,
      order_id: @order.id
    }
  end

  def shipper_update_order
    @order = Order.find_by id: params[:id]
    @order.update_attributes status: params[:status]
    user_name = "HỆ THỐNG"
    if params[:status] == "3"
      @message = Message.new order_id: @order.id, message: "Đã nhận được hàng. Đang trên đường giao hàng..."
      @message.save
      date_time = l @message.created_at, format: :short
      ActionCable.server.broadcast "chat_with_user_#{@order.user_id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name,
        receiver: true
      ActionCable.server.broadcast "chat_with_user_#{current_user.id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name
    else
      @message = Message.new order_id: @order.id, message: "Đơn hàng #" + @order.id.to_s + " đã được giao thành công."
      @message.save
      @shipper = Shipper.find_by id: @order.shipper_id
      @shipper.update_attributes status: 1
      ActionCable.server.broadcast "chat_with_user_#{@order.user_id}_channel",
        content: :order_food_out
    end
  end

  def add_message
    @order = Order.find_by id: params[:order_id]
    @shipper = Shipper.find_by id: @order.shipper_id
    @message = Message.new order_id: @order.id, message: params[:chat_content], user_id: current_user.id
    @message.save
    date_time = l @message.created_at, format: :short
    user_name = if @order.user_id == current_user.id
                  current_user.name
                else
                  "[Shipper] " + current_user.name
                end
    if @order.user_id == current_user.id
      ActionCable.server.broadcast "chat_with_user_#{@order.user_id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name,
        image: current_user.avatar_url
      ActionCable.server.broadcast "chat_with_user_#{@shipper.user_id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name,
        image: current_user.avatar_url,
        receiver: true
    else
      @message.update_attributes is_shipper: true
      ActionCable.server.broadcast "chat_with_user_#{@order.user_id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name,
        image: current_user.avatar_url,
        receiver: true
      ActionCable.server.broadcast "chat_with_user_#{@shipper.user_id}_channel",
        content: :order_food,
        message: @message.message,
        order_id: @order.id,
        date_time: date_time,
        user_name: user_name,
        image: current_user.avatar_url
    end
  end

  private

  def place_params
    params.require(:place).permit :name, :phone, :email, :website, :category_id,
      :province_id, :address, :detail_direction, :description, :capacity,
      :start_time, :close_time
  end

  def object_place_create
    @place = Place.new place_params
    @place.user_id = current_user.id
    @place.longitude = params[:longitude]
    @place.latitude = params[:latitude]
  end

  def find_place
    @place = Place.find_by id: params[:id]
    return if @place
    flash.now[:danger] = t "flash.not_found.place"
    redirect_to profiles_path
  end

  def add_food food_key, quantity = 1
    check_cookie_cart
    if @foods.key? food_key
      @food_exist = 1
      @foods[food_key] += quantity
    else
      @foods[food_key] = quantity
    end
    update_cookie_cart @foods
  end

  def check_cookie_cart
    cookie_name = "foods_" + params[:id] + "_" + current_user.id.to_s if current_user.present?
    @foods = cookies[cookie_name]
    return @foods = Hash.new if @foods.blank?
    @foods = JSON.parse cookies[cookie_name]
  end

  def update_cookie_cart foods
    cookie_name = "foods_" + params[:id] + "_" + current_user.id.to_s
    cookies.permanent[cookie_name] = JSON.generate foods
  end

  def get_subtotal_price foods
    total_price = 0
    foods.keys.each do |key|
      price_final = 0
      key.split(",").each do |id|
        @food = Food.find_by id: id
        price_food = @food.price
        price_food = @food.discount if @food.discount.present?
        price_final += price_food
      end
      total_price += price_final * foods[key].to_i
    end
    total_price
  end

  def delete_food key
    check_cookie_cart
    return @foods unless @foods.key?(key)
    @foods.delete key
    update_cookie_cart @foods
  end

  def update_food key, quantity
    check_cookie_cart
    @foods[key] = quantity
    update_cookie_cart @foods
  end

  def save_product_order foods
    foods.each do |key, value|
      parent_id = 0
      key.split(",").each do |fo_item|
        @food = Food.find_by id: fo_item
        if @food.is_optional.zero?
          price_food = @food.price
          price_food = @food.discount if @food.discount.present?
          @product_order = @order.product_orders.new(food_id: fo_item.to_i,
            quantity: value, actual_price: price_food)
          @product_order.save
          parent_id = @product_order.id
        else
          @product_order = @order.product_orders.new(food_id: fo_item.to_i,
            quantity: value, actual_price: @food.price, parent_id: parent_id)
          @product_order.save
        end
      end
    end
    cookies.delete "foods_" + params[:id] + "_" + current_user.id.to_s
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/BlockLength
end
