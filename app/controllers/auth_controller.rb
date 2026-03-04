require "net/http"
require "uri"
require "json"

class AuthController < ApplicationController
  def install
    shop = params[:shop]

    state = SecureRandom.hex(16)
    cookies[:shopify_oauth_state] = state

    redirect_to oauth_url(shop, state)
  end

  def callback
    shop = params[:shop]
    code = params[:code]
    state = params[:state]

    return head :unauthorized unless state == cookies[:shopify_oauth_state]

    access_token = fetch_access_token(shop, code)

    shop_record = save_shop(shop, access_token)

    register_webhooks(shop_record)

    redirect_to "/dashboard"
  end
  private

  def oauth_url(shop, state)
    query = {
      client_id: ENV["SHOPIFY_API_KEY"],
      scope: ENV["SHOPIFY_SCOPES"],
      redirect_uri: "#{ENV["SHOPIFY_APP_URL"]}/auth/callback",
      state: state
    }.to_query

    "https://#{shop}/admin/oauth/authorize?#{query}"
  end

  def fetch_access_token(shop, code)
    uri = URI("https://#{shop}/admin/oauth/access_token")

    response = Net::HTTP.post(
      uri,
      {
        client_id: ENV["SHOPIFY_API_KEY"],
        client_secret: ENV["SHOPIFY_API_SECRET"],
        code: code
      }.to_json,
      "Content-Type" => "application/json"
    )

    JSON.parse(response.body)["access_token"]
  end

  def save_shop(shop, access_token)
    record = Shop.find_or_initialize_by(shopify_domain: shop)

    record.update!(
      access_token: access_token,
      installed: true,
      uninstalled_at: nil
    )

    record
  end

  def register_webhooks(shop)
    topics = %w[APP_UNINSTALLED ORDERS_CREATE PRODUCTS_UPDATE]

    topics.each do |topic|
      create_webhook(shop, topic)
    end
  end

  def create_webhook(shop, topic)
    uri = URI("https://#{shop.shopify_domain}/admin/api/2024-01/graphql.json")

    mutation = {
      query: <<~GRAPHQL
      mutation {
        webhookSubscriptionCreate(
          topic: #{topic},
          webhookSubscription: {
            callbackUrl: "#{ENV["SHOPIFY_APP_URL"]}/webhooks/#{topic.downcase}",
            format: JSON
          }
        ) {
          userErrors {
            field
            message
          }
        }
      }
    GRAPHQL
    }

    Net::HTTP.post(
      uri,
      mutation.to_json,
      {
        "Content-Type" => "application/json",
        "X-Shopify-Access-Token" => shop.access_token
      }
    )
  end
end
