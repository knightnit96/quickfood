class RatesController < ApplicationController
  include RatesHelper
  before_action :find_review, only: :destroy
  before_action :find_place, only: %i(create destroy)

  def create
    place_id = params[:place_id]
    @rate = Rate.new place_id: place_id,
      rating: params[:rating], content: params[:content],
      user_id: current_user.id
    Rate.transaction do
      @rate.save
      load_reviews
      renderhtml_reviews @reviews, place_id
      update_rating_and_render
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to place_path id: place_id
  end

  def destroy
    Rate.transaction do
      @review.destroy
      load_reviews
      renderhtml_reviews @reviews, params[:place_id]
      update_rating_and_render
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to place_path id: params[:place_id]
  end

  private

  def load_reviews
    @reviews = Rate.place_reviews(params[:place_id]).by_date
    return if @reviews
    flash.now[:danger] = t "helpers.error[review_not_found]"
  end

  def update_rating_and_render
    overall = 0
    counter_reviews = 0
    if @reviews.present?
      overall = @reviews.average(:rating).round(1)
      counter_reviews = @reviews.count(:rating)
    end
    @place.update_attribute :rating, overall
    render json: {
      overall: overall,
      counter_reviews: counter_reviews,
      reviews: @reviews_html
    }
  end

  def find_review
    @review = Rate.find_by id: params[:review_id]
    return if @review
    flash[:danger] = t "helpers.error[review_not_found]"
    redirect_back_or product_path id: params[:product_id]
  end

  def find_place
    @place = Place.activated.find_by id: params[:place_id]
    return if @place
    flash[:danger] = t "helpers.error[product_not_found]"
    redirect_to list_path
  end
end
