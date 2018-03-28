class HomeController < ApplicationController
  def index
    debugger
    @webhooks = ShopifyAPI::Webhook.find(:all)
  end
end
