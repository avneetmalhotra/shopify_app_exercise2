class SettingsController < ApplicationController

  before_action :fetch_setting, only: :edit
  before_action :get_setting, only: [:update, :modify_theme]

  def edit
  end

  def update
    if @setting.update(update_setting_params)
      flash[:notice] = I18n.t(:file_successfully_uploaded, scope: [:flash, :notice])
    else
      flash[:error] = @setting.pretty_errors
    end
    redirect_to edit_setting_path(@setting)
  end

  def modify_theme
    if params[:modify_theme] == 'yes'
      @setting.enqueue_modify_theme_job
      redirect_to edit_setting_path(@setting)
    end
  end


  private

    def update_setting_params
      params.require(:setting).permit(discount_uploads_attributes: [:discount])
    end

    def fetch_setting
      @setting = current_shop.discount_upload_setting
      if @setting.blank?
        render_404
      end
    end

    def get_setting
      @setting = Setting.find_by(id: params[:id])
      if @setting.blank?
        render_404
      end
    end

end
