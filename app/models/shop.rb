# frozen_string_literal: true

class Shop < ActiveRecord::Base
  include ShopifyApp::ShopSessionStorage

  has_many :product_batches, dependent: :destroy
  has_many :variant_settings, dependent: :destroy

  def api_version
    ShopifyApp.configuration.api_version
  end
  def installed?
    installed
  end
end
