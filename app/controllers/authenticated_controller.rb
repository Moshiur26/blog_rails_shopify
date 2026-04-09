# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureHasSession
  before_action :ensure_current_shop_record!

  helper_method :current_shop

  private

  def current_shop
    @current_shop ||= Shop.find_by(shopify_domain: @current_shopify_session&.shop || params[:shop].to_s)
  end

  def ensure_current_shop_record!
    return if current_shop.present?

    head :not_found
  end
end
