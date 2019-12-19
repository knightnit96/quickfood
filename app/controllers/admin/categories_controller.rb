class Admin::CategoriesController < Admin::ApplicationController
  before_action :find_category, except: %i(new create index)
  before_action :check_active

  authorize_resource

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new category_params
    if @category.save
      flash[:success] = t "flash.create.success.admin_category"
      redirect_to admin_categories_path
    else
      flash.now[:error] = t "flash.create.fail.admin_category"
      render :new
    end
  end

  def edit; end

  def update
    if @category.update_attributes category_params
      flash[:success] = t "flash.update.success.admin_category"
      redirect_to admin_categories_path
    else
      flash.now[:error] = t "flash.update.fail.admin_category"
      render :edit
    end
  end

  def destroy
    if @category.destroy
      flash[:success] = t "flash.delete.success.admin_category"
    else
      flash[:danger] = t "flash.delete.fail.admin_category"
    end
    redirect_to admin_categories_path
  end

  private

  def category_params
    params.require(:category).permit :name
  end

  def find_category
    @category = Category.find_by id: params[:id]
    return if @category
    flash[:danger] = t "flash.not_found.admin_category"
    redirect_to admin_path
  end

  def check_active
    @active = "category"
  end
end
