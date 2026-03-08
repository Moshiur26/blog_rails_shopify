# Production Folder Structure

This app now uses Rails for backend concerns and React (via Vite) for the embedded Shopify UI.

## Current structure

- `app/controllers/`
  - `api/v1/`: versioned JSON API for frontend clients.
  - root controllers: auth, session, webhook entrypoints.
- `app/frontend/`
  - `entrypoints/`: Vite/Rails entry files.
  - `features/`: business features grouped by domain (`products`, `webhooks`).
  - `components/`: shared UI components.
  - `hooks/`: reusable React hooks.
  - `lib/`: app bridge + API utilities.
  - `styles/`: global frontend styling.
- `app/models/`: persistence and validations.
- `app/services/`: business service objects (for Shopify-specific logic, QR generation, etc.).
- `app/views/`: Rails shells/layouts plus React mount points.
- `config/`
  - `routes.rb`: route map (web + API namespaces).
  - `vite.json`: Vite Ruby integration config.
- `docs/`: architecture and operational docs.

## Recommended growth pattern

- Add new backend API features under `app/controllers/api/v1/<domain>_controller.rb`.
- Add matching React domain modules under `app/frontend/features/<domain>/`.
- Keep cross-cutting logic in:
  - `app/services/` (Ruby)
  - `app/frontend/lib/` and `app/frontend/hooks/` (React)
- When introducing breaking API changes, add `api/v2` instead of modifying `api/v1` in place.
