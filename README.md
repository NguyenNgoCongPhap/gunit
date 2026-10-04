# gunit

Compile-time unit-label safety for Gleam: a pure-Gleam unit-brand library with no FFI. Its guarantee is
compile-time label safety, not dimensional analysis or cross-quantity algebra.

## Owns

- Every physical-quantity and dimensionless semantic brand used by Gleam consumers, including a brand with
  one display unit or no conversion ladder.
- The conversions between units of one family, each factor stored once in its owning module.

## Refuses

- Entity, member and section IDs (`gids` owns those), wire formats, UI tokens and COM unit state.
- Wire-unit authority: Rust's unit brands are the wire contract; gunit is the Gleam-side brand owner, not a
  second wire schema.
- App-local unit types or copied conversion tables in a consumer: a missing brand is added here.

## Catalog

One entry per capability in `docs/features/*.toml`, checked in CI by `scripts/verify_catalog.py`.
