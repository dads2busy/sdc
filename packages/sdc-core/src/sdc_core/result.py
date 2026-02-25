"""Standard result type returned by pipeline run() functions.

Every run() should return a RunResult so the CLI and web API can
display consistent status information.

Usage:
    from sdc_core.result import RunResult

    return RunResult(
        success=True,
        rows=len(df),
        output_path="data/distribution/gender.csv.xz",
        duration_sec=42.1,
    )
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class RunResult:
    """Outcome of a pipeline step."""

    success: bool
    rows: int = 0
    output_path: str = ""
    duration_sec: float = 0.0
    error: str = ""
    warnings: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "success": self.success,
            "rows": self.rows,
            "output_path": self.output_path,
            "duration_sec": round(self.duration_sec, 2),
            "error": self.error,
            "warnings": self.warnings,
        }
