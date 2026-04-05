# frozen_string_literal: true

class HomeController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::EnsureInstalled
  include ShopifyApp::EnsureHasSession
  include ShopifyApp::ShopAccessScopesVerification

  def index
    if ShopifyAPI::Context.embedded? && (!params[:embedded].present? || params[:embedded] != "1")
      redirect_to(ShopifyAPI::Auth.embedded_app_url(params[:host]) + request.path, allow_other_host: true)
    else
      @shop_origin = current_shopify_domain
      @host = params[:host]
      @product_data = {
        shopOrigin: @shop_origin,
        host: @host,
        products: bootstrap_products
      }
    end
  end

  private

  def bootstrap_products
    ShopifyAPI::Product.all(limit: 10).map do |product|
      {
        id: product.id,
        title: product.title,
        handle: product.handle
      }
    end
  rescue StandardError => e
    Rails.logger.error("bootstrap_products failed: #{e.class} - #{e.message}")
    []
  end
end
