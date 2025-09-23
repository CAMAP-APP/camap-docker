# CAMAP Monorepo Rules

## Structure
- **Haxe apps**: `camap-hx/`
  - `backend/`: Haxe backend (build with `build.hxml`)
  - `frontend/`: Haxe frontend (build with `build.hxml`)
- **TypeScript apps**: `camap-ts/`
  - `packages/api-core/`: NestJS backend (TS)
  - `packages/front-core/`: React frontend (TS)

## Scope & Boundaries
- Haxe code changes are confined to `camap-hx/`.
- TypeScript/JavaScript code changes are confined to `camap-ts/`.
- Do not couple `camap-hx` and `camap-ts` at build/runtime unless explicitly requested.

## Conventions
- Prefer absolute paths from the workspace for commands and tool calls.
- Preserve existing indentation style (tabs vs spaces) exactly as-is in edited files.
- Keep answers concise; write code with clarity and explicitness.

## Builds & Scripts
- Haxe: drive builds via `*.hxml` files and scripts within `camap-hx/*`.
- TypeScript: use package scripts inside `camap-ts/packages/*`.

## PR / Change Guidance
- Isolate edits by language/package.
- Add/update documentation alongside meaningful changes where it helps future maintainers.

## Evolution
- Haxe project is being deprecated
- Prefer improvements on the TS project
- If possible move the logic from Haxe towards TS