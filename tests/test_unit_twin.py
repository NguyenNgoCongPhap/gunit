# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""Real artifact, process and compiled-consumer controls for the generated twin."""

import contextlib
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import Any
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import unit_twin as twin
import verify_catalog as catalog
from process_tools import GateToolError, process_owner, run

ROOT = Path(__file__).resolve().parents[1]


def commit_control(root: Path) -> str:
    """Commit one real controlled tree without using signing credentials or bypassing hooks."""
    run(["git", "init", "--initial-branch=main", "--quiet"], root=root)
    run(["git", "add", "."], root=root)
    run(
        [
            "git",
            "-c",
            "commit.gpgsign=false",
            "-c",
            "user.name=Cong Phap",
            "-c",
            "user.email=phapnnc@daidung.vn",
            "commit",
            "--quiet",
            "-m",
            "Producer control",
        ],
        root=root,
    )
    return run(["git", "rev-parse", "HEAD"], root=root).strip()


class TwinControls(unittest.TestCase):
    def setUp(self) -> None:
        scratch = ROOT / "_scratch/tests"
        scratch.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=scratch)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        shutil.copytree(ROOT / "docs/features", self.root / "docs/features")
        for name in ["unit-twin.toml", twin.LOCK]:
            shutil.copyfile(ROOT / name, self.root / name)
        self.source = twin.declaration(self.root)
        for name in [
            self.source["contract"],
            *[item["destination"] for item in self.source["artifacts"]],
        ]:
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / name, target)
        self.lock = twin.verify_local(self.root, self.source)

    def test_positive_local_provenance_and_each_opposite_artifact(self) -> None:
        self.assertEqual(twin.verify_local(self.root, self.source), self.lock)
        for item in self.source["artifacts"]:
            path = self.root / item["destination"]
            before = path.read_bytes()
            path.write_bytes(before + b"opposite artifact\n")
            with self.assertRaisesRegex(ValueError, "output drift"):
                twin.verify_local(self.root, self.source)
            path.write_bytes(before)

    def test_stale_head_and_remote_movement_refuse_without_writes(self) -> None:
        before = (self.root / twin.LOCK).read_bytes()
        with (
            patch.object(twin, "remote_head", return_value="f" * 40),
            self.assertRaisesRegex(ValueError, "behind"),
        ):
            twin.generate(self.root, write=False)
        outputs = [
            (item, (self.root / item["destination"]).read_bytes(), locked["blob"])
            for item, locked in zip(self.source["artifacts"], self.lock["artifacts"], strict=True)
        ]
        with (
            patch.object(twin, "remote_head", side_effect=[self.lock["commit"], "f" * 40]),
            patch.object(twin, "producer_bytes", return_value=outputs),
            self.assertRaisesRegex(ValueError, "moved during collection"),
        ):
            twin.generate(self.root, write=False)
        self.assertEqual((self.root / twin.LOCK).read_bytes(), before)

    def test_schema_paths_and_generated_claim_drift_refuse(self) -> None:
        for name in [".", "../outside", "/outside", "src/file:stream", "src\\file"]:
            with self.subTest(name=name), self.assertRaises(ValueError):
                twin.repository_path(self.root, name)
        path = self.root / twin.LOCK
        value = dict(self.lock, schema_version=True)
        path.write_text(json.dumps(value), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "schema"):
            twin.verify_local(self.root, self.source)
        path.write_text(json.dumps(self.lock), encoding="utf-8")
        contract = self.root / self.source["contract"]
        contract.write_text(
            contract.read_text().replace("1024.0 byte-base", "1023.0 byte-base"), encoding="utf-8"
        )
        with self.assertRaisesRegex(ValueError, "catalog facts drift"):
            twin.verify_local(self.root, self.source)

    def test_generated_index_rejects_an_opposite_row(self) -> None:
        index = self.root / "docs/features/index.md"
        index.write_text(index.read_text() + "| opposite catalog row |\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "catalog index drift"):
            twin.verify_local(self.root, self.source)

    def test_generated_index_symlink_refuses_before_write(self) -> None:
        index = self.root / "docs/features/index.md"

        def is_index(path: Path) -> bool:
            return path == index

        with (
            patch.object(Path, "is_symlink", autospec=True, side_effect=is_index),
            self.assertRaisesRegex(ValueError, "symlink"),
        ):
            twin.write_contract_facts(self.root, self.source)

    def test_published_metadata_schema_refuses_before_any_output_write(self) -> None:
        metadata_path = next(
            item["destination"]
            for item in self.source["artifacts"]
            if item["destination"].endswith(".json")
        )
        original = json.loads((ROOT / metadata_path).read_bytes())
        invalid = [dict(original, schema_version=value) for value in [True, 1.0, 2, "1"]]
        absent = dict(original)
        absent.pop("schema_version")
        invalid.append(absent)
        paths = [
            twin.LOCK,
            self.source["contract"],
            "docs/features/index.md",
            *[item["destination"] for item in self.source["artifacts"]],
        ]
        original_run = twin.run
        for number, document in enumerate(invalid):
            with self.subTest(schema=document.get("schema_version", "absent")):
                producer = self.root / f"producer-{number}"
                for item in self.source["artifacts"]:
                    path = producer / item["source"]
                    path.parent.mkdir(parents=True, exist_ok=True)
                    data = (
                        json.dumps(document).encode()
                        if item["destination"] == metadata_path
                        else (ROOT / item["destination"]).read_bytes()
                    )
                    path.write_bytes(data)
                commit_control(producer)

                def transport(
                    command: list[str],
                    *,
                    root: Path = ROOT,
                    network: bool = False,
                    producer_path: Path = producer,
                ) -> str:
                    redirected = [
                        str(producer_path) if arg == self.source["repository"] else arg
                        for arg in command
                    ]
                    return original_run(redirected, root=root, network=network)

                before = {name: (self.root / name).read_bytes() for name in paths}
                with (
                    patch.object(twin, "run", side_effect=transport),
                    self.assertRaisesRegex(ValueError, "metadata schema"),
                ):
                    twin.generate(self.root, write=True)
                self.assertEqual({name: (self.root / name).read_bytes() for name in paths}, before)


class ProcessControls(unittest.TestCase):
    def setUp(self) -> None:
        scratch = ROOT / "_scratch/tests"
        scratch.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=scratch)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.producer = self.root / "producer"
        self.producer.mkdir()
        (self.producer / "input").write_text("process control\n", encoding="utf-8")
        run(["git", "init", "--quiet"], root=self.producer)
        run(["git", "add", "."], root=self.producer)
        run(
            [
                "git",
                "-c",
                "commit.gpgsign=false",
                "-c",
                "user.name=Cong Phap",
                "-c",
                "user.email=phapnnc@daidung.vn",
                "commit",
                "--quiet",
                "-m",
                "Process control",
            ],
            root=self.producer,
        )
        self.head = run(["git", "rev-parse", "HEAD"], root=self.producer).strip()

    def test_child_git_context_is_isolated(self) -> None:
        before = (self.producer / ".git/config").read_bytes()
        child = self.root / "child"
        child.mkdir()
        with patch.dict(
            os.environ,
            {"GIT_DIR": str(self.producer / ".git"), "GIT_WORK_TREE": str(self.producer)},
        ):
            run(["git", "init", "--bare", "--quiet"], root=child)
        self.assertEqual((self.producer / ".git/config").read_bytes(), before)
        self.assertTrue((child / "HEAD").is_file())

    def test_missing_reviewed_owner_refuses_before_child(self) -> None:
        marker = self.root / "marker"
        command = [
            sys.executable,
            "-c",
            "from pathlib import Path; Path('marker').write_text('observed')",
        ]
        run(command, root=self.root)
        self.assertEqual(marker.read_text(), "observed")
        with patch.dict(os.environ, {"REPO_SEED": ""}), self.assertRaises(GateToolError):
            run(
                [sys.executable, "-c", "from pathlib import Path; Path('refused').touch()"],
                root=self.root,
            )
        self.assertFalse((self.root / "refused").exists())

    def test_transient_transport_retries_then_reads_real_remote(self) -> None:
        owner = process_owner()
        original = owner.subprocess.run
        attempts = 0

        def child(command: list[str], **arguments: Any) -> subprocess.CompletedProcess[str]:
            nonlocal attempts
            attempts += 1
            if attempts == 1:
                raise subprocess.CalledProcessError(
                    1, command, output="", stderr="Could not resolve host"
                )
            return original(command, **arguments)

        with (
            patch.object(owner.subprocess, "run", side_effect=child),
            patch.object(owner.time, "sleep") as sleep,
        ):
            result = run(
                ["git", "ls-remote", str(self.producer), "HEAD"], root=self.root, network=True
            )
        self.assertIn(self.head, result)
        self.assertEqual(attempts, 2)
        sleep.assert_called_once_with(1)

    def test_real_refusal_does_not_retry(self) -> None:
        owner = process_owner()
        with patch.object(owner.time, "sleep") as sleep, self.assertRaises(GateToolError):
            run(
                ["git", "ls-remote", str(self.root / "absent"), "HEAD"],
                root=self.root,
                network=True,
            )
        sleep.assert_not_called()


class CatalogControls(unittest.TestCase):
    def test_unlabelled_ghost_factor_and_test_citation_refusals(self) -> None:
        scratch = ROOT / "_scratch/tests"
        scratch.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=scratch) as directory:
            root = Path(directory)
            for name in ["src", "test", "docs/features"]:
                shutil.copytree(ROOT / name, root / name)
            entry = root / "docs/features/feat.units.information_size.v1.toml"
            original = entry.read_text(encoding="utf-8")
            with patch.object(catalog, "REPO", root):
                with contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(catalog.main(), 0)
                for value, expected in [
                    (
                        original.replace("schema_version = 1", "schema_version = true"),
                        "schema_version",
                    ),
                    (original.replace('brands = ["Bytes"]', 'brands = ["Ghost"]'), "brand Ghost"),
                    (
                        original.replace("1024.0 byte-base", "1023.0 byte-base"),
                        "claim does not state",
                    ),
                    (
                        original.replace("information_size_byte_base_test", "absent_golden_test"),
                        "cited test does not exist",
                    ),
                    (
                        original.replace("feat.units.information_size.v1", "feat.units.ghost.v1"),
                        "does not match filename",
                    ),
                ]:
                    entry.write_text(value, encoding="utf-8")
                    output = io.StringIO()
                    with contextlib.redirect_stdout(output):
                        self.assertEqual(catalog.main(), 1)
                    self.assertIn(expected, output.getvalue())
                entry.write_text(original, encoding="utf-8")
                unlabelled = root / "src/gunit/uncatalogued.gleam"
                unlabelled.write_text(
                    "pub opaque type Uncatalogued { Uncatalogued(value: Float) }\n",
                    encoding="utf-8",
                )
                output = io.StringIO()
                with contextlib.redirect_stdout(output):
                    self.assertEqual(catalog.main(), 1)
                self.assertIn("modules have no catalog entry", output.getvalue())


class CompiledConsumerControls(unittest.TestCase):
    def test_public_javascript_boundary_checks_nonfinite_inputs_and_decoder(self) -> None:
        run(["gleam", "build", "--target", "javascript"])
        base = ROOT / "build/dev/javascript"
        quantity = (base / "gunit/gunit/information_size.mjs").as_uri()
        decoder = (base / "gleam_stdlib/gleam/dynamic/decode.mjs").as_uri()
        program = (
            "import assert from 'node:assert/strict';"
            f"import*as quantity from {json.dumps(quantity)};"
            f"import*as decoder from {json.dumps(decoder)};"
            "const positive=quantity.bytes(512);assert.equal(positive.isOk(),true);"
            "assert.equal(quantity.to_bytes(positive[0]),512);"
            "for(const input of [NaN,Infinity,-Infinity]){"
            "const result=quantity.bytes(input);assert.equal(result.isOk(),false);"
            "assert.ok(result[0] instanceof quantity.NonFinite);"
            "assert.equal(decoder.run(input,quantity.decoder()).isOk(),false);}"
            "console.log('compiled quantity and decoder refusals observed');"
        )
        self.assertIn("refusals observed", run(["node", "--input-type=module", "-e", program]))
