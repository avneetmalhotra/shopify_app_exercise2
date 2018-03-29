class OrdersCreateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    shop.with_shopify_session do
      customer = Customer.find_by(email: webhook[:email])
      if customer.present?
        customer.remove_advance_discount_code
      end
    end
  end
end
