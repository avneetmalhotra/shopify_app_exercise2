class ApplicationController < ShopifyApp::AuthenticatedController

  helper_method :current_shop

  def current_shop
    @current_shop ||= Shop.find_by(shopify_domain: session[:shopify_domain])
  end

  def render_404
    render file: Rails.root.join('public', '404.html'), status: 404 and return
  end
end
