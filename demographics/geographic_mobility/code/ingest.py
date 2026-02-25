"""Ingest geographic mobility data from ACS.

Configuration is read from geographic_mobility/pipeline.yaml.
"""

import time
from pathlib import Path

import pandas as pd
import yaml

from sdc_core.census import CensusClient
from sdc_core.io import write_data
from sdc_core.log import get_logger
from sdc_core.result import RunResult

TOPIC_DIR = Path(__file__).resolve().parents[1]
log = get_logger("geographic_mobility.ingest")


def load_config() -> dict:
    with open(TOPIC_DIR / "pipeline.yaml") as f:
        return yaml.safe_load(f)


def compute_measures(df: pd.DataFrame) -> pd.DataFrame:
    """Compute percentage of population that moved in the past year."""
    df = df.copy()
    df["perc_moving"] = 100 * df["pop_moving"] / df["total_pop"]

    id_cols = ["geoid", "year", "region_type"]
    long = df[id_cols + ["perc_moving"]].melt(
        id_vars=id_cols,
        var_name="measure",
        value_name="value",
    )
    long["moe"] = pd.NA
    return long.dropna(subset=["value"])


def run(pipeline=None) -> RunResult:
    t0 = time.time()
    try:
        config = load_config()
        src = config["source"]
        out = config["output"]

        log.info("Starting geographic mobility ingest (profile=%s)", src.get("profile"))

        client = CensusClient()
        df = client.get_acs_multi(
            variables=src["variables"],
            years=src["years"],
            geographies=src["geographies"],
            profile=src.get("profile"),
            states=src.get("states"),
        )
        log.info("Fetched %d raw rows from Census API", len(df))

        result = compute_measures(df)

        out_dir = TOPIC_DIR / out["path"]
        out_path = write_data(result, out_dir / out["filename"])
        log.info("Wrote %d rows to %s", len(result), out_path)

        return RunResult(
            success=True,
            rows=len(result),
            output_path=str(out_path),
            duration_sec=time.time() - t0,
        )
    except Exception as e:
        log.error("Geographic mobility ingest failed: %s", e, exc_info=True)
        return RunResult(
            success=False,
            error=str(e),
            duration_sec=time.time() - t0,
        )


if __name__ == "__main__":
    result = run()
    if not result.success:
        raise SystemExit(1)
