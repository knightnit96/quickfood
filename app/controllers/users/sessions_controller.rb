class Users::SessionsController < Devise::SessionsController
  before_action :set_locale, except: :destroy

  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect resource_or_scope, resource
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    cookies.permanent[:user] = resource.id
    if current_user.role == "admin"
      render json: {success: true, admin: true}
    else
      render json: {success: true}
    end
  end

  def failure
    warden.custom_failure!
    render json: {success: false, errors: t("flash.login.error_invalid")}
  end

  def destroy
    cookies.delete :user
    cookies.delete :shipper
    @shipper = Shipper.find_by user_id: current_user.id
    if @shipper.present?
      if @shipper.status == 1
        @shipper.update_attributes(status: 0, latitude: nil, longitude: nil)
      end
    end
    super
  end

  protected

  def auth_options
    {scope: resource_name, recall: "#{controller_path}#failure"}
  end

  private

  def set_locale
    I18n.locale = params[:user][:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
