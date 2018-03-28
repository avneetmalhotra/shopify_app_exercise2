class DiscountSettingMailer < ApplicationMailer

  def invalid_customers_list_columns_email(discount_setting_id)
    discount_setting = DiscountSetting.find_by id: discount_setting_id
    shop = discount_setting.shop

    mail(to: shop.shopify_email, subject: "Incorrect #{discount_setting.customers_list_file_name} file.", from: 'notification@development-store-a2.com')
  end

  def invalid_customers_list_data_email(discount_setting_id)
    discount_setting = DiscountSetting.find_by id: discount_setting_id
    shop = discount_setting.shop
    attachments['file-data-issues.txt'] = File.read(discount_setting.customers_list_data_errors.path)

    mail(to: shop.shopify_email, subject: "Incorrect #{discount_setting.customers_list_file_name} file.", from: 'notification@development-store-a2.com')
  end

end
