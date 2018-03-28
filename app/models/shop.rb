class Shop < ApplicationRecord
  include ShopifyApp::SessionStorage

  has_many :settings, dependent: :destroy

  before_create :build_associated_settings

  after_commit :add_email

  private

    def build_associated_settings
      settings.build({ name: 'Upload Discount Files' })
    end

    def add_email
      with_shopify_session do
        update_columns(shopify_email: ShopifyAPI::Shop.current.email)
      end
    end

end
