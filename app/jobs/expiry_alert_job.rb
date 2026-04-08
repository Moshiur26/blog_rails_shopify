class ExpiryAlertJob < ApplicationJob
  queue_as :default

  def perform
    Shop.find_each do |shop|
      Inventory::ExpiryAlertService.new(shop: shop).call
    end
  end
end
