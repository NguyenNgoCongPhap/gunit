# gunit

Compile-time **unit-label safety** for Gleam — SI and common metric units —
with conversion factors pinned by golden tests.

Each unit (`Millimeter`, `Meter`, `Newton`, `Kilonewton`, `Megapascal`, ...) is a
distinct opaque type, so the compiler rejects passing one where another is
expected. Mixing `mm` with `m`, or `kPa` with `MPa`, becomes a compile error
instead of a silent bug.

```gleam
import gunit/force
import gunit/pressure

let demand = force.kilonewton(120.0) // Kilonewton
let fy = pressure.megapascal(345.0)  // Megapascal
```

```gleam
// Does not type-check — that's the point.
let bad = length.add(length.millimeter(10.0), length.meter(2.0))
//                   ^^^^^^^^^^^^^^^^^^^^^^^^ add expects Meter, got Millimeter
```

Type names are spelled out in full (`Kilonewton`, not `Kn`) on purpose: Gleam
types are PascalCase, which would collapse SI case and make a short `Mn` / `Mpa`
ambiguous between mega- and milli-.

## Label safety, not dimensional analysis

Gleam has no type-level arithmetic, so — unlike Rust [`uom`](https://docs.rs/uom)
— `length / time -> speed` is not derived for you; you write explicit conversion
functions. The trade is deliberate: a small, robust core. Conversions route
through one SI base per family, and every factor is pinned by a golden test
(forward AND inverse) against a cited source.

## Units

| Family   | Units                                                            | Base   |
| -------- | ---------------------------------------------------------------- | ------ |
| length   | `Millimeter` `Centimeter` `Meter`                                | meter  |
| force    | `Newton` `Kilonewton` `Meganewton` `KilogramForce` `TonneForce`  | newton |
| pressure | `Pascal` `Kilopascal` `Megapascal` `Gigapascal` `KgfPerCm2`      | pascal |
| moment   | `NewtonMeter` `KilonewtonMeter` `KilogramForceMeter` `TonneForceMeter` | N.m |
| angle    | `Radian` `Degree`                                                | radian |

Each module gives: a constructor + value extractor per unit, `to_base` /
`from_base` conversions, and `add` / `subtract` / `scale` on the family's base
unit (compute in the base, label at the edges).

## Install

Not on Hex — add it as a git dependency in your `gleam.toml`:

```toml
[dependencies]
gunit = { git = "https://github.com/NguyenNgoCongPhap/gunit.git", ref = "v0.1.0" }
```

Then `gleam deps download`.

## Maintenance policy

> **AI-assisted code — set expectations accordingly.** Much of this library is
> generated with AI assistance and reviewed by one person. Read the source, and
> run the golden-tested factors against your own reference values before
> trusting any number in critical work.

A personal project, shared in case it's useful. Open source, not open support:

- **Correctness bug reports are welcome** — a wrong conversion factor, with a
  citation, is something I will always fix.
- Feature requests and API-taste changes I may decline.
- MIT licence — warranty disclaimed.

## Licence

MIT — see [LICENSE](LICENSE).
