# Shopify Blog App

Embedded Shopify app using Rails for backend APIs, webhooks, and server-rendered views.

## Tech stack

- Rails 8
- Shopify App gem

## Setup

1. Install Ruby gems:
   - `bundle install`
2. Run the app in development:
   - `bin/dev`

## API routes

- `GET /api/v1/products`
- `GET /api/v1/products/:id/qr_code`
- `GET /api/v1/webhook_events`

## Structure guide

See `docs/PROJECT_STRUCTURE.md` for the production-oriented folder layout and growth pattern.
