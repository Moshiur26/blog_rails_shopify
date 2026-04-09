# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureHasSession
  before_action :ensure_current_shop_record!
  before_action :set_embedded_app_context

  helper_method :current_shop, :app_context_params

  private

  def current_shop
    @current_shop ||= Shop.find_by(shopify_domain: @current_shopify_session&.shop || params[:shop].to_s)
  end

  def app_context_params
    {}.tap do |context|
      context[:shop] = current_shop.shopify_domain if current_shop&.shopify_domain.present?
      context[:host] = params[:host] if params[:host].present?
    end
  end

  def ensure_current_shop_record!
    return if current_shop.present?

    head :not_found
  end

  def set_embedded_app_context
    @shop_origin = current_shop&.shopify_domain || @current_shopify_session&.shop
    @host = params[:host]
  end
end
