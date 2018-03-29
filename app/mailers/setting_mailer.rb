class SettingMailer < ApplicationMailer

  def theme_successfully_modified_email(shop_id)
    @shop = Shop.find_by id: shop_id

    mail(to: @shop.shopify_email, subject: 'Theme successully modified')
  end

  def theme_modification_failed_email(shop_id)
    @shop = Shop.find_by id: shop_id

    mail(to: @shop.shopify_email, subject: 'Theme modification failed')
  end
end
