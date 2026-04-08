module Inventory
  class BatchAllocator
    class InsufficientStockError < StandardError; end

    def initialize(shopify_variant_id:, quantity:, today: Date.current)
      @shopify_variant_id = shopify_variant_id.to_s
      @quantity = quantity.to_i
      @today = today
    end

    def call
      raise ArgumentError, "quantity must be positive" if quantity <= 0

      allocations = []

      ProductBatch.transaction do
        batches = ProductBatch
          .for_variant(shopify_variant_id)
          .available_on(today)
          .where("quantity > 0")
          .order(:expiry_date, :created_at, :id)
          .lock

        remaining = quantity
        available = batches.sum(&:quantity)

        if available < remaining
          raise InsufficientStockError, "Insufficient stock for variant #{shopify_variant_id}"
        end

        batches.each do |batch|
          break if remaining.zero?

          deducted = [batch.quantity, remaining].min
          batch.update!(quantity: batch.quantity - deducted)
          allocations << { batch_id: batch.id, batch_number: batch.batch_number, deducted_quantity: deducted }
          remaining -= deducted
        end
      end

      allocations
    end

    private

    attr_reader :quantity, :shopify_variant_id, :today
  end
end
