class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def app_uninstalled
    return head :unauthorized unless valid_webhook?

    shop_domain = request.headers["X-Shopify-Shop-Domain"]
    webhook_id  = request.headers["X-Shopify-Webhook-Id"]

    # Idempotency check
    return head :ok if ProcessedWebhook.exists?(webhook_id: webhook_id)

    AppUninstalledJob.perform_later(shop_domain, webhook_id)

    head :ok
  end

  def order_create
    return head :unauthorized unless valid_webhook?

    webhook_id = request.headers["X-Shopify-Webhook-Id"].to_s
    shop_domain = request.headers["X-Shopify-Shop-Domain"].to_s
    return head :bad_request if webhook_id.blank? || shop_domain.blank?
    return head :ok if ProcessedWebhook.exists?(webhook_id: webhook_id)

    raw_body = request.raw_post
    payload = JSON.parse(raw_body)
    shop = Shop.find_by(shopify_domain: shop_domain)
    return head :not_found if shop.blank?

    ActiveRecord::Base.transaction do
      WebhookEvent.create!(
        topic: "orders/create",
        shop_domain: shop_domain,
        webhook_id: webhook_id,
        payload: payload,
        received_at: Time.current
      )

      Array(payload["line_items"]).each do |line_item|
        variant_id = line_item["variant_id"].presence
        quantity = line_item["quantity"].to_i
        next if variant_id.blank? || quantity <= 0

        Inventory::BatchAllocator.new(shop: shop, shopify_variant_id: variant_id, quantity: quantity).call
      end

      ProcessedWebhook.create!(webhook_id: webhook_id)
    end

    Shopify::InventorySync.new(
      shop: shop,
      variant_ids: Array(payload["line_items"]).filter_map { |line_item| line_item["variant_id"]&.to_s }
    ).call

    head :ok
  rescue ActiveRecord::RecordNotUnique
    head :ok
  rescue Inventory::BatchAllocator::InsufficientStockError => e
    Rails.logger.error("Order allocation failed for webhook #{webhook_id}: #{e.message}")
    head :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Order webhook processing failed for webhook #{webhook_id}: #{e.message}")
    head :unprocessable_entity
  rescue Shopify::InventorySync::SyncError => e
    Rails.logger.error("Order webhook inventory sync failed for webhook #{webhook_id}: #{e.message}")
    head :ok
  rescue JSON::ParserError
    head :bad_request
  end

  def products_update
    process_payload_webhook!("products/update")
  end

  def orders_create
    order_create
  end

  private

  def process_payload_webhook!(expected_topic)
    return head :unauthorized unless valid_webhook?

    webhook_id = request.headers["X-Shopify-Webhook-Id"].to_s
    shop_domain = request.headers["X-Shopify-Shop-Domain"].to_s
    return head :bad_request if webhook_id.blank? || shop_domain.blank?
    return head :ok if ProcessedWebhook.exists?(webhook_id: webhook_id)

    raw_body = request.raw_post
    payload = JSON.parse(raw_body)

    ActiveRecord::Base.transaction do
      WebhookEvent.create!(
        topic: expected_topic,
        shop_domain: shop_domain,
        webhook_id: webhook_id,
        payload: payload,
        received_at: Time.current
      )

      ProcessedWebhook.create!(webhook_id: webhook_id)
    end

    head :ok
  rescue ActiveRecord::RecordNotUnique
    head :ok
  rescue JSON::ParserError
    head :bad_request
  end

  def valid_webhook?
    hmac_header = request.headers["X-Shopify-Hmac-Sha256"].to_s
    body = request.raw_post

    return false if hmac_header.blank?

    digest  = OpenSSL::Digest.new("sha256")
    secret  = ENV["SHOPIFY_API_SECRET"]

    return false if secret.blank?

    calculated_hmac = Base64.strict_encode64(
      OpenSSL::HMAC.digest(digest, secret, body)
    )

    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
  rescue ArgumentError
    false
  end
end
