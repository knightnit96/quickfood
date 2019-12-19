class Admin::DashboardController < Admin::ApplicationController
  authorize_resource class: false

  def index
    @total_users = User.count
    @total_shippers = Shipper.count
    @total_places = Place.is_activated_and_not_proposal.count
    @total_ratings = Rate.count
    @active = "dashboard"
    @places = Place.by_proposal(true).by_date
    @shippers = Shipper.activated.by_date
  end

  def profile; end
end
