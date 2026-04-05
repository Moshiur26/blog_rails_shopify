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
   - This uses `vite build --watch` (no Vite dev server) for stable embedded rendering in Shopify Admin.

## Embedded dev stability mode

This app is configured to avoid iframe/HMR issues in embedded Shopify pages:

- Layouts load only built JS bundles via `vite_javascript_tag`.
- `Procfile.dev` runs `npm run build:watch` instead of `vite dev`.

If frontend changes are not visible, make sure the `vite` process from `bin/dev` is running.

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
