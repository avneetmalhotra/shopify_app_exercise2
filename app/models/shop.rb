class Shop < ApplicationRecord
  include ShopifyApp::SessionStorage

  ## ASSOCIATIONS
  has_many :settings, dependent: :destroy
  has_one :discount_upload_setting, -> { where(name: DISCOUNT_UPLOAD_SETTING_NAME) }, class_name: 'Setting'

  ## CALLBACKS
  before_create :build_associated_settings
  after_commit :add_email

  private

    def build_associated_settings
      settings.build({ name: DISCOUNT_UPLOAD_SETTING_NAME })
    end

    def add_email
      with_shopify_session do
        update_columns(shopify_email: ShopifyAPI::Shop.current.email)
      end
    end

end
