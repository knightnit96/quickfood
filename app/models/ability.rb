# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize current_user, controller_namespace
    can %i(new create), User
    can %i(show index), Place
    return if current_user.blank?
    case controller_namespace
    when Settings.controller.namespace_for_admin
      can :manage, :all if current_user.admin?
    else
      # authorize_to_user current_user
      can :manage, :all
    end
  end

  # private

  # def authorize_to_user current_user
  #   if current_user.customer?
  #     can :show, User, id: current_user.id
  #     can %i(create show), Order, user_id: current_user.id
  #     can :destroy, ItemPhoto
  #     can :manage, HistoryOrdersController
  #     can :manage, RequestsController
  #     can %i(create destroy), Comment, user_id: current_user.id
  #     can %i(create destroy), Rate, user_id: current_user.id
  #   else
  #     can :manage, :all
  #   end
  # end
end
