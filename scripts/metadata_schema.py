# SPDX-FileCopyrightText: Cong Phap
# SPDX-License-Identifier: LicenseRef-Proprietary
"""One explicit schema-version boundary for generated and authored metadata."""


def require_schema_version(document: object, expected_version: int, document_name: str) -> None:
    """Refuse absent, non-integer or unsupported versions before interpreting the document."""
    if (
        not isinstance(document, dict)
        or type(document.get("schema_version")) is not int
        or document["schema_version"] != expected_version
    ):
        raise ValueError(f"unsupported {document_name} schema_version")
