class Admin::ApplicationController < ApplicationController
  layout "admin/application"

  before_action :load_list_places_is_proposal

  private

  def current_ability
    @current_ability ||=
      Ability.new current_user, Settings.controller.namespace_for_admin
  end

  def load_list_places_is_proposal
    @list_places_proposal = Place.by_proposal(true).count
  end
end
