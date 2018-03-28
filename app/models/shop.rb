class Shop < ApplicationRecord
  include ShopifyApp::SessionStorage

  has_many :discount_setting, dependent: :destroy

  after_commit :add_email

  private

    def add_email
      with_shopify_session do
        update_columns(shopify_email: ShopifyAPI::Shop.current.email)
      end
    end

end
