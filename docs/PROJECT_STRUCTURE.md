# Production Folder Structure

This app uses Rails for backend concerns and server-rendered UI.

## Current structure

- `app/controllers/`
  - `api/v1/`: versioned JSON API endpoints.
  - root controllers: auth, session, webhook entrypoints.
- `app/models/`: persistence and validations.
- `app/services/`: business service objects (for Shopify-specific logic, QR generation, etc.).
- `app/views/`: Rails shells, layouts, and server-rendered pages.
- `config/`
  - `routes.rb`: route map (web + API namespaces).
- `docs/`: architecture and operational docs.

## Recommended growth pattern

- Add new backend API features under `app/controllers/api/v1/<domain>_controller.rb`.
- Keep cross-cutting logic in:
  - `app/services/` (Ruby)
- When introducing breaking API changes, add `api/v2` instead of modifying `api/v1` in place.
