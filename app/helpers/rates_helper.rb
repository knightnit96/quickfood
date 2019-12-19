module RatesHelper
  def renderhtml_reviews reviews, place_id
    @reviews_html = Array.new
    reviews.each do |review|
      append_div review, place_id
      @reviews_html << @div
    end
    @review_html
  end

  def append_div review, place_id
    @div = "<div class='review_strip_single review_item' style='display:none'>"
    @div += "<img src='" + review.user.avatar.url + "' alt='' class='img-circle' width='50px'>"
    @div += "<h4>" + review.user.name
    if review.user.id == current_user.id
      @div += "<a class='delete_review_btn' data_id='" + review.id.to_s + "' pid='" + place_id + "' href='javascript:void(0)'><i class='icon-trash'></i></a>"
    end
    @div += "</h4>"
    @div += "<div class='rating'>"
    review.rating.times.each do
      @div += "<i class='icon_star voted'></i>"
    end
    @div += "<small>" + l(review.updated_at, format: :short) + "</small>"
    @div += "</div>"
    @div += "<p class='nomargin'>" + review.content + "</p>"
    @div += "</div>"
  end
end
