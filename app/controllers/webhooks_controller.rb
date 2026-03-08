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

  def orders_create
    process_payload_webhook!("orders/create")
  end

  def products_update
    process_payload_webhook!("products/update")
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
