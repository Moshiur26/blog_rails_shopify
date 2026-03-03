class AppUninstalledJob < ActiveJob::Base
  include ShopifyAPI::Webhooks::WebhookHandler

  def self.handle(topic:, shop:, body:, webhook_id:, api_version:)
    perform_later(topic: topic, shop_domain: shop, webhook: body)
  end

  def handle(data:)
    perform_later(topic: data.topic, shop_domain: data.shop, webhook: data.body)
  end

  def perform(topic:, shop_domain:, webhook:)
    # Find the shop by its domain (e.g., "example-store.myshopify.com")
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      return # Exit gracefully if the shop is already gone
    end

    # 1. Clear any sensitive data or perform cleanup logic here
    # 2. Finally, destroy the shop record so they can re-install fresh later
    shop.destroy

    logger.info("AppUninstalledJob: Successfully removed shop data for #{shop_domain}")
  end
end
