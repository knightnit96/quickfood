module ApplicationHelper
  include IconHelper

  def full_title page_title
    base_title = "Quick food"
    if page_title.blank?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def load_page counter
    @page = params[:page].nil? ? 1 : params[:page].to_i
    (@page - 1) * Kaminari.config.default_per_page + counter + 1
  end

  def number_to_currency_format number
    if /\A[-+]?\d+\z/.match?(number.to_s) || /\A[+-]?(\d+\.\d+)?\Z/.match?(number.to_s)
      Money.new(number.to_f.round(3), "VND").format
    else
      number
    end
  end

  def load_parent_province province_id
    if province_id.present?
      province = Province.find_by id: province_id
      parent_province = Province.find_by id: province.parent_id
      [parent_province.id, parent_province.name]
    end
  end

  def load_province province_id
    province = Province.find_by id: province_id
    [province.id, province.name]
  end

  def load_list_child_province province_id
    province = Province.find_by id: province_id
    @list_provinces = Province.parent_only province.parent_id
  end

  def list_menu_item parent_id
    Food.parent_only parent_id
  end

  def list_menu_option_checkbox parent_id
    Food.parent_only(parent_id).is_optional_only(1)
  end

  def list_menu_option_radio parent_id
    Food.parent_only(parent_id).is_optional_only(2)
  end

  def list_address user_id
    @addresses = Address.by_user user_id
  end
end
