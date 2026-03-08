# frozen_string_literal: true

module Api
  module V1
    class WebhookEventsController < BaseController
      def index
        events = WebhookEvent.order(received_at: :desc).limit(25)

        render json: {
          events: events.map do |event|
            {
              webhook_id: event.webhook_id,
              topic: event.topic,
              shop_domain: event.shop_domain,
              received_at: event.received_at
            }
          end
        }
      end
    end
  end
end
