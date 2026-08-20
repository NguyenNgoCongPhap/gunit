# gunit feature catalog

This is a hand-written, curated index. It is not generated.

| ID | Name | Status | Intensity | Intent |
| --- | --- | --- | --- | --- |
| [feat.units.angle.v1](feat.units.angle.v1.toml) | Angle brands and conversions | completed | calc | Prevents degree and radian mix-ups while providing explicit conversion and Radian-only arithmetic. |
| [feat.units.area.v1](feat.units.area.v1.toml) | Area brands and conversions | completed | calc | Keeps square-millimeter, square-centimeter, and square-meter values distinct while routing conversion and arithmetic through SquareMeter. |
| [feat.units.density.v1](feat.units.density.v1.toml) | Density brands and conversions | completed | calc | Separates supported mass-density representations and provides explicit conversion and arithmetic through kilograms per cubic meter. |
| [feat.units.dimensionless.v1](feat.units.dimensionless.v1.toml) | Dimensionless semantic brands | completed | light | Prevents dimensionless engineering values with different meanings from being interchanged at function signatures. |
| [feat.units.force.v1](feat.units.force.v1.toml) | Force brands and conversions | completed | calc | Separates SI, gravitational-metric, and US-customary force values while routing explicit conversion and arithmetic through Newton. |
| [feat.units.frequency.v1](feat.units.frequency.v1.toml) | Frequency brand | completed | light | Brands modal-analysis frequency values as Hz so they cannot be silently confused with unlabelled or time-domain Floats. |
| [feat.units.inertia.v1](feat.units.inertia.v1.toml) | Second moment of area brand | completed | light | Brands second moment of area in mm4 so section-property values cannot be passed as unrelated Floats. |
| [feat.units.length.v1](feat.units.length.v1.toml) | Length brands and conversions | completed | calc | Separates metric and US-customary lengths while routing explicit conversion and arithmetic through Meter. |
| [feat.units.mass.v1](feat.units.mass.v1.toml) | Mass brands and conversions | completed | calc | Separates gram, kilogram, and metric-tonne mass values while routing explicit conversion and arithmetic through Kilogram. |
| [feat.units.moment.v1](feat.units.moment.v1.toml) | Moment brands and conversions | completed | calc | Separates supported bending-moment representations while routing explicit conversion and arithmetic through NewtonMeter. |
| [feat.units.pressure.v1](feat.units.pressure.v1.toml) | Pressure and stress brands and conversions | completed | calc | Separates Pascal-based and kilogram-force-per-square-centimeter values while routing explicit conversion and arithmetic through Pascal. |
| [feat.units.stiffness.v1](feat.units.stiffness.v1.toml) | Stiffness semantic brands | completed | light | Keeps translational and rotational spring stiffness values distinct at partial-fixity and other structural signatures. |
| [feat.units.time.v1](feat.units.time.v1.toml) | Time brands and conversions | completed | calc | Separates second and millisecond durations while providing explicit conversion and Second-only arithmetic. |
