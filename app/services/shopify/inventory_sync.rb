require "json"
require "net/http"
require "uri"

module Shopify
  class InventorySync
    class SyncError < StandardError; end

    def initialize(shop:, variant_ids: nil, location_id: nil)
      @shop = shop
      @variant_ids = Array(variant_ids).compact_blank.map(&:to_s).uniq
      @location_id = location_id
    end

    def call
      raise ArgumentError, "shop is required" if shop.blank?

      location = location_id.presence || fetch_primary_location_id
      inventory_by_variant.each do |variant_id, quantity|
        sync_variant!(variant_id, quantity, location)
      end
    end

    private

    attr_reader :location_id, :shop, :variant_ids

    def inventory_by_variant
      scope = shop.product_batches.available_on
      scope = scope.where(shopify_variant_id: variant_ids) if variant_ids.any?

      totals = scope.group(:shopify_variant_id).sum(:quantity)
      return totals if variant_ids.empty?

      variant_ids.index_with { |variant_id| totals[variant_id] || 0 }
    end

    def sync_variant!(variant_id, quantity, location)
      inventory_item_id = fetch_inventory_item_id(variant_id)
      raise SyncError, "Missing inventory item for variant #{variant_id}" if inventory_item_id.blank?

      response = graphql_request(
        <<~GRAPHQL,
          mutation inventorySetQuantities($input: InventorySetQuantitiesInput!) {
            inventorySetQuantities(input: $input) {
              userErrors {
                field
                message
              }
            }
          }
        GRAPHQL
        variables: {
          input: {
            name: "available",
            reason: "correction",
            ignoreCompareQuantity: true,
            quantities: [
              {
                inventoryItemId: inventory_item_id,
                locationId: location,
                quantity: quantity
              }
            ]
          }
        }
      )

      errors = response.dig("data", "inventorySetQuantities", "userErrors") || []
      return if errors.empty?

      raise SyncError, errors.map { |error| error["message"] }.join(", ")
    end

    def fetch_primary_location_id
      response = graphql_request(
        <<~GRAPHQL
          query {
            locations(first: 1) {
              edges {
                node {
                  id
                }
              }
            }
          }
        GRAPHQL
      )

      response.dig("data", "locations", "edges", 0, "node", "id").tap do |id|
        raise SyncError, "No Shopify location available for inventory sync" if id.blank?
      end
    end

    def fetch_inventory_item_id(variant_id)
      response = graphql_request(
        <<~GRAPHQL,
          query productVariantInventoryItem($id: ID!) {
            productVariant(id: $id) {
              inventoryItem {
                id
              }
            }
          }
        GRAPHQL
        variables: { id: graphql_variant_id(variant_id) }
      )

      response.dig("data", "productVariant", "inventoryItem", "id")
    end

    def graphql_variant_id(variant_id)
      value = variant_id.to_s
      value.start_with?("gid://") ? value : "gid://shopify/ProductVariant/#{value}"
    end

    def graphql_request(query, variables: {})
      uri = URI("https://#{shop.shopify_domain}/admin/api/#{ShopifyApp.configuration.api_version}/graphql.json")
      response = Net::HTTP.post(
        uri,
        { query: query, variables: variables }.to_json,
        {
          "Content-Type" => "application/json",
          "X-Shopify-Access-Token" => shop.shopify_token
        }
      )

      body = JSON.parse(response.body)
      if response.code.to_i >= 400 || body["errors"].present?
        raise SyncError, Array(body["errors"]).map { |error| error["message"] || error.to_s }.join(", ").presence || response.body
      end

      body
    rescue JSON::ParserError => e
      raise SyncError, e.message
    end
  end
end
