ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = ENV['shopifyapp_api_key']
  config.secret = ENV['shopifyapp_secret']
  config.scope = "read_customers, write_customers, read_price_rules, write_price_rules, read_themes, write_themes, read_orders, write_orders"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.session_repository = Shop
  config.webhooks = [
    {topic: 'orders/create', address: 'https://be6c22fe.ngrok.io/webhooks/orders_create', format: 'json'},
  ]
end
