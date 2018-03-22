ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = ENV['shopifyapp_api_key']
  config.secret = ENV['shopifyapp_secret']
  config.scope = "read_customers, write_customers, read_orders, write_orders, read_draft_orders, write_draft_orders, read_price_rules, write_price_rules, read_checkouts, write_checkouts,"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.session_repository = Shop
end
