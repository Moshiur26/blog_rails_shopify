class ExpiryAlertJob < ApplicationJob
  queue_as :default

  def perform
    Inventory::ExpiryAlertService.new.call
  end
end
