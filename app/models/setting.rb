class Setting < ApplicationRecord

  attr_accessor :cart_template, :theme_modification_failed
  ## ASSOCATIONS
  belongs_to :shop
  has_many :discount_uploads
  accepts_nested_attributes_for :discount_uploads

  ## VALIDATIONS
  validates :name, presence: true

  def enqueue_modify_theme_job
    ModifyThemeJob.perform_later(id)  
  end

  def modify_theme
    fetch_cart_template
    unless @theme_modification_failed
      create_cart_template_backup
      patch_theme_changes
    end
  end

  private

  def fetch_cart_template
    begin
      shop.with_shopify_session do
        @cart_template = ShopifyAPI::Asset.find('sections/cart-template.liquid')
      end
    rescue ActiveRecord::ResourceNotFound => exception
      @theme_modification_failed = true
      send_theme_modification_failure_email
    end
  end

  def create_cart_template_backup
    shop.with_shopify_session do
      ShopifyAPI::Asset.create(key: 'sections/cart-template-orignal.liquid', value: @cart_template.value)
    end
  end

  def patch_theme_changes
    shop.with_shopify_session do

      unless theme_already_modified?
        temp = @cart_template.value.split(ENV['cart_template_string_to_search'])
      
        if temp.size == 2
          cart_template_new_value = temp.join(ENV['cart_template_string_to_search'] + ENV['cart_template_code_to_insert'])
          @cart_template.value = cart_template_new_value
          @cart_template.save ? send_successful_theme_modification_email : send_theme_modification_failure_email

        else
          theme_modification_failed = true
          send_theme_modification_failure_email
        end
      
      else
        send_successful_theme_modification_email
      end
    end
  end

  def theme_already_modified?
    @cart_template.value.include?(ENV['cart_template_code_to_insert'])
  end

  def send_theme_modification_failure_email
    SettingMailer.theme_modification_failed_email(shop.id).deliver_later
  end

  def send_successful_theme_modification_email
    SettingMailer.theme_successfully_modified_email(shop.id).deliver_later
  end
end
