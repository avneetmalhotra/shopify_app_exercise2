class Customer < ApplicationRecord

  delegate :shop, to: :discount_upload
  ## ASSOCATIONS
  belongs_to :discount_upload

  ## VALIDATIONS
  validates :shopify_customer_id, :shopify_price_rule_id, numericality: { only_integer: true }, allow_blank: true

  validates :discount_amount, presence: true, numericality: { greater_than: 0.01 }, allow_blank: true
  validates :email, presence: true, format:{
    with: Regexp.new(ENV['email_regex']),
    allow_blank: true
  }
  validate :ensure_customer_exists

  ## CALLBACKS
  before_create :set_shopify_customer_id
  before_create :create_price_rule
  after_create :create_advance_discount_code_metafield


  def pretty_errors
    errors.full_messages.join(', ')
  end

  def remove_advance_discount_code
    delete_advance_discount_code_metafield
  end

  private

  def delete_advance_discount_code_metafield
    shop.with_shopify_session do
      shopify_customer = ShopifyAPI::Customer.search(query: "email:#{email}").first
      shopify_customer_advance_discount_code_metafield = shopify_customer.metafields.find.detect{ |metafield| metafield.key == 'advance_discount_code' }

      if shopify_customer_advance_discount_code_metafield.present?
        shopify_customer_advance_discount_code_metafield.destroy
        update(advance_discount_code: 'used')
      end
    end
  end

  def set_shopify_customer_id
    shop.with_shopify_session do
      self.shopify_customer_id = ShopifyAPI::Customer.search(query: "email:#{email}").first.id
    end
  end

  def create_price_rule
    shop.with_shopify_session do
      price_rule = ShopifyAPI::PriceRule.create(title: generate_price_rule_title, target_type: 'line_item', target_selection: 'all', allocation_method: 'across', value_type: 'fixed_amount', value: discount_amount*(-1), customer_selection: 'prerequisite', prerequisite_customer_ids: [shopify_customer_id], starts_at: Time.current, usage_limit: 1)
      discount_code = ShopifyAPI::DiscountCode.create(code: price_rule.title, price_rule_id: price_rule.id)
      self.advance_discount_code = discount_code.code
      self.shopify_discount_code_id = discount_code.id
      self.shopify_price_rule_id = price_rule.id
    end
  end

  def create_advance_discount_code_metafield
    shop.with_shopify_session do
      metafield = ShopifyAPI::Metafield.create(key: 'advance_discount_code', value: advance_discount_code, value_type: 'string', namespace: 'global', owner_id: shopify_customer_id, owner_resource: 'customer')
    end
  end

  def generate_price_rule_title
    loop do 
      title = SecureRandom.hex(16)
      break title unless self.class.where(advance_discount_code: title).exists?
    end
  end

  def ensure_customer_exists
    shop.with_shopify_session do
      unless ShopifyAPI::Customer.search(query: "email:#{email}").size
        errors[:email] << "Doesn't belong to any user."
      end
    end
  end

end
