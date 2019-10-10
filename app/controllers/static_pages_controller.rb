class StaticPagesController < ApplicationController
  before_action :load_list_parent_provinces
  before_action :load_categories

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  def home
    province_id = cookies[:province]
    @provinces.each do |province|
      if province.to_slug_province(province.name) == params[:province]
        province_id = province.id
        cookies[:province] = province_id
      end
    end
    @province = Province.find_by id: province_id
    @places = Place.is_activated_and_not_proposal
    @total_users = User.count
    @total_shippers = Shipper.count
    @list_provinces = Province.parent_only(province_id).pluck(:id)
    @place_search = Place.is_activated_and_not_proposal.by_province(@list_provinces).count
    @list_provinces = Province.parent_only(province_id)
    @places_popular = Place.is_activated_and_not_proposal.by_province(@list_provinces.pluck(:id)).by_status(1)
    @places_popular.each do |place|
      order = Order.by_place(place.id).by_status(4).count
      place.count_order = order
    end
    @places_popular = @places_popular.sort_by(&:count_order).reverse
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/LineLength

  def contact; end

  def about
    @places = Place.is_activated_and_not_proposal
  end

  def faq; end
end
