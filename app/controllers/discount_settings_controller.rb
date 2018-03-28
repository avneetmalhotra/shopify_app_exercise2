class DiscountSettingsController < ApplicationController

  def new
    @discount_setting = current_shop.discount_setting.build
  end

  def create
    @discount_setting = current_shop.discount_setting.build(discount_setting_params)
    if @discount_setting.save
      flash[:notice] = I18n.t(:setting_updated_successfully, scope: [:flash, :notice])
    else
      flash[:error] = @setting.pretty_errors
    end
    redirect_to new_discount_setting_path
  end

  private

    def discount_setting_params
      params.require(:discount_setting).permit(:customers_list)
    end

end
