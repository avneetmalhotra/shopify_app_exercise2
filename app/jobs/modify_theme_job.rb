class ModifyThemeJob < ApplicationJob

  def perform(setting_id)
    setting = Setting.find_by(id: setting_id)
    setting.modify_theme
  end
end
