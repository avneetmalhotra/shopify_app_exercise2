class HomeController < ApplicationController
  def index
    @webhooks = ShopifyAPI::Webhook.find(:all)
    @discount_setting = current_shop.discount_upload_setting
  end
end
