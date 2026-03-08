# Shopify Blog App (Rails + React)

Embedded Shopify app using Rails for backend APIs/webhooks and React (via Vite) for the view layer.

## Tech stack

- Rails 8
- Shopify App gem
- React 19
- Vite + `vite_rails`

## Setup

1. Install Ruby gems:
   - `bundle install`
2. Install frontend deps:
   - `npm install`
3. Run the app in development:
   - `bin/dev`

## Frontend architecture

- React source: `app/frontend`
- Entry point: `app/frontend/entrypoints/application.jsx`
- Feature modules: `app/frontend/features/*`
- API client + app bridge helpers: `app/frontend/lib/*`

## API routes used by React

- `GET /api/v1/products`
- `GET /api/v1/products/:id/qr_code`
- `GET /api/v1/webhook_events`

## Structure guide

See `docs/PROJECT_STRUCTURE.md` for the production-oriented folder layout and growth pattern.
