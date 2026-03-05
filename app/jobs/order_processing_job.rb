class OrderProcessingJob < ApplicationJob
  queue_as :default

  def perform(data)
    # business logic
  end
end
