class OrdersCreateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    shop.with_shopify_session do
      customer = Customer.where(email: webhook[:email]).where.not(advance_discount_code: 'used').first
      if customer.present?
        customer.remove_advance_discount_code
      end
    end
  end
end
