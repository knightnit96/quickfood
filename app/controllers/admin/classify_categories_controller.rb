class Admin::ClassifyCategoriesController < Admin::ApplicationController
  before_action :find_classify_category, except: %i(new create index)
  before_action :load_classify_category_parent, only: %i(new edit)
  before_action :check_active

  authorize_resource

  def index
    @classify_categories = ClassifyCategory.sort_by_parent
  end

  def new
    @classify_category = ClassifyCategory.new
  end

  # rubocop:disable Metrics/LineLength
  def create
    @classify_category = ClassifyCategory.new classify_category_params.merge(icon: params[:icon_classify_category])
    if @classify_category.save
      flash[:success] = t "flash.create.success.admin_classify_category"
      redirect_to admin_classify_categories_path
    else
      flash.now[:error] = t "flash.create.fail.admin_classify_category"
      render :new
    end
  end
  # rubocop:enable Metrics/LineLength

  def edit; end

  def update
    if @classify_category.update_attributes classify_category_params
      flash[:success] = t "flash.update.success.admin_classify_category"
      redirect_to admin_classify_categories_path
    else
      flash.now[:error] = t "flash.update.fail.admin_classify_category"
      render :edit
    end
  end

  def destroy
    if @classify_category.destroy
      flash[:success] = t "flash.delete.success.admin_classify_category"
    else
      flash[:danger] = t "flash.delete.fail.admin_classify_category"
    end
    redirect_to admin_classify_categories_path
  end

  private

  def classify_category_params
    params.require(:classify_category).permit :name, :icon, :parent_id
  end

  def find_classify_category
    @classify_category = ClassifyCategory.find_by id: params[:id]
    return if @classify_category
    flash[:danger] = t "flash.not_found.admin_classify_category"
    redirect_to admin_path
  end

  def check_active
    @active = "classify_category"
  end

  def load_classify_category_parent
    @cc_parents = ClassifyCategory.parent_only nil
  end
end
