# 2. API Contract Source of Truth

Date: 2026-05-22

## Status

Accepted

## Context

Crab has multiple contract surfaces: `docs/openapi.yaml`, `docs/API.md`, PostgreSQL bootstrap SQL, NestJS TypeORM and Mongoose models, shared TypeScript types, Socket.IO event packages, Flutter models, and the web-admin client. The audit found those surfaces can drift independently, especially around ride and food-order status vocabularies.

## Decision

`docs/openapi.yaml` is the REST API source of truth for external HTTP contracts, and `packages/common-types` is the source of truth for shared TypeScript enums used by backend and web-admin code. Socket.IO payloads remain owned by `packages/socket-events`. Database bootstrap SQL and prose docs must mirror those canonical enums rather than introducing independent lifecycle names.

Contract changes must follow this order:

1. Update this ADR or add a superseding ADR when the contract ownership model changes.
2. Update `docs/openapi.yaml` for REST shape changes.
3. Update `packages/common-types` and `packages/socket-events` for enum or event payload changes.
4. Update backend DTOs/entities and client models.
5. Run the contract drift check and targeted workspace validation.

## Consequences

### Positive

- REST clients have one stable contract file to generate or validate against.
- Shared enum changes become visible to both backend and web-admin builds.
- Bootstrap SQL and prose docs stop silently inventing status names.

### Negative

- Existing Flutter models are not generated from OpenAPI yet, so manual drift is still possible until client generation is introduced.
- TypeORM/Mongoose schemas still require follow-up alignment to enforce enum constraints at persistence boundaries.

### Neutral

- This ADR does not rewrite existing tables or run destructive migrations. Schema changes must ship as explicit migrations after the current data shape is audited.

## Alternatives considered

- **Database-first contract:** rejected because the platform has both PostgreSQL and MongoDB persistence plus non-DB Socket.IO payloads.
- **Common-types-only contract:** rejected because Flutter cannot consume TypeScript types directly and REST consumers need an OpenAPI artifact.
- **Immediate generated clients everywhere:** deferred because it requires broader build and client restructuring beyond a safe foundation step.

## References

- `docs/openapi.yaml` REST contract.
- `docs/RIDE_MATCHING.md` and `docs/FOOD_DELIVERY.md` lifecycle vocabulary.
- `packages/common-types/src/index.ts` shared enums.
