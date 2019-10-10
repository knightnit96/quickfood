class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :load_province_cookie
  before_action :load_list_parent_provinces
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_list_orders

  helper_method :resource_name, :resource, :devise_mapping, :resource_class

  # rubocop:disable Style/IdenticalConditionalBranches
  rescue_from CanCan::AccessDenied do
    if user_signed_in?
      flash[:danger] = t "flash.warning[not_authorized]"
      redirect_to root_path
    else
      flash[:danger] = t "flash.warning[login_cancan]"
      redirect_to root_path
    end
  end
  # rubocop:enable Style/IdenticalConditionalBranches

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def page_404
    render file: "public/404.html", layout: false
  end

  private

  def configure_permitted_parameters
    added_attrs = [:email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, "")
  end

  # rubocop:disable Metrics/LineLength
  def load_list_parent_provinces
    @provinces = Province.parent_only nil
    @provinces.each do |province|
      @list_provinces_child = Province.parent_only(province.id).pluck(:id)
      place = Place.is_activated_and_not_proposal.by_province(@list_provinces_child).count
      province.count_place = place
    end
    @provinces = @provinces.sort_by(&:count_place).reverse
    @provinces.each do |province|
      province.key_name = province.to_slug_province province.name
    end
  end

  def load_parent_classify_categories
    @parent_classify_categories = ClassifyCategory.parent_only nil
  end

  def load_categories
    @categories = Category.all
  end

  def load_list_orders
    @shipper = Shipper.find_by user_id: current_user.id if current_user.present?
    @shipper_id = 0
    @shipper_id = @shipper.id if @shipper.present?
    @orders_shipper_user = if current_user.present?
                             Order.by_user_or_shipper(current_user.id, @shipper_id).by_status([0, 1, 2, 3])
                           end
  end

  def load_province_cookie
    cookies[:province] = 1 if cookies[:province].blank?
    @province = Province.find_by id: cookies[:province]
    @list_provinces_count = Province.parent_only(cookies[:province]).pluck(:id)
    @place_count = Place.is_activated_and_not_proposal.by_province(@list_provinces_count).count
  end
  # rubocop:enable Metrics/LineLength
end
