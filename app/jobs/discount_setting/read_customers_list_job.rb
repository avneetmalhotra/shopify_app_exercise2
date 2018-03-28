class DiscountSetting::ReadCustomersListJob < ApplicationJob

  def perform(discount_setting_id)
    @discount_setting = DiscountSetting.find_by id: discount_setting_id
    @discount_setting.read_customers_list
    @discount_setting.ensure_customers_list_is_valid

    if @discount_setting.customers_list_error_type.present?
      @discount_setting.send_invalid_customers_list_email
    else
      @discount_setting.create_associated_customers      
    end
  end
end
