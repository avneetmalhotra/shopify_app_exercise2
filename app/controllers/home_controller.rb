class HomeController < ApplicationController
  def index
    debugger
    @webhooks = ShopifyAPI::Webhook.find(:all)
    @discount_setting = current_shop.settings.where(name: 'Upload Discount Files')
  end
end
