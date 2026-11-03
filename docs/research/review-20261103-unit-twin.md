# Generated twin review triage

The first free final-head review identified one P2 release-conformance defect: producer metadata could retain valid scales while omitting or changing schema_version, allowing the writer and subsequent check to succeed. The current producer artifact was read back and confirms schema_version 1.

The finding is blocking and fixed as a class. One schema boundary now validates manifests, locks, producer metadata, feature contracts and generated index inputs before their fields are interpreted. Producer metadata is checked immediately after its exact fetched blob is verified, before any output, lock or contract write.

Five real local Git producers demonstrated the bug with missing, boolean, floating-point, string and unsupported integer schema versions; each case was observed red before the fix. Each now refuses, with every consumer output read back byte-identical to its pre-call state. The authored catalog's boolean schema case was independently red before the same boundary was applied there. The whole suite now includes 12 Python controls alongside 93 Gleam JavaScript tests.

The sweep covers declaration, producer_bytes, factor_claims, verify_local, write_contract_facts, catalog_index and entry_problems. No generated quantity source, producer metadata blob or library version changed during the fix. The coordinator owns the clean exact-head standing gate.

A further P2 identified semantic validation occurring after writes: a version-1 producer metadata blob claimed 1023.0 for kibibytes while its Gleam source retained 1024.0. A real Git producer reproduced the refusal after the consumer metadata and lock had already changed. Preparation now happens in a disposable tree: fetched bytes, schema/factor relationships, lock, contract facts and the complete generated index are validated before any consumer file is replaced. A final head recheck precedes publication. The counterexample now leaves every consumer output unchanged, and a valid real producer is published and read back successfully. The suite is now 93 Gleam tests and 14 Python controls.
