"""Ingest population density data from ACS + TIGER land area.

Configuration is read from population_density/pipeline.yaml.
"""

import time
from pathlib import Path

import httpx
import pandas as pd
import yaml

from sdc_core.census import CensusClient
from sdc_core.io import write_data
from sdc_core.log import get_logger
from sdc_core.result import RunResult

TOPIC_DIR = Path(__file__).resolve().parents[1]
log = get_logger("population_density.ingest")

TIGER_URL = "https://tigerweb.geo.census.gov/arcrest/tigerweb/tigerWMS_ACS2020/MapServer/{layer}/query"
SQ_METERS_PER_SQ_MILE = 2_589_988.11


def load_config() -> dict:
    with open(TOPIC_DIR / "pipeline.yaml") as f:
        return yaml.safe_load(f)


def fetch_land_area(tiger_config: dict) -> pd.DataFrame:
    """Fetch land area for tracts and counties from TIGER API."""
    state_fips = tiger_config["state_fips"]
    layers = [
        (tiger_config["tract_layer"], "tract"),
        (tiger_config["county_layer"], "county"),
    ]

    records = []
    for layer, geo_type in layers:
        log.info("Fetching %s land area from TIGER (layer %d)", geo_type, layer)
        params = {
            "where": f"STATE='{state_fips}'",
            "outFields": "GEOID,AREALAND",
            "returnGeometry": "false",
            "f": "json",
        }
        resp = httpx.get(TIGER_URL.format(layer=layer), params=params, timeout=60)
        resp.raise_for_status()
        data = resp.json()
        for feat in data.get("features", []):
            attrs = feat["attributes"]
            records.append({
                "geoid": str(attrs["GEOID"]),
                "land_area_sqmi": attrs["AREALAND"] / SQ_METERS_PER_SQ_MILE,
                "region_type": geo_type,
            })

    log.info("Fetched land area for %d geographies", len(records))
    return pd.DataFrame(records)


def run(pipeline=None) -> RunResult:
    t0 = time.time()
    try:
        config = load_config()
        src = config["source"]
        tiger = config["tiger"]
        out = config["output"]

        log.info("Starting population density ingest (profile=%s)", src.get("profile"))

        client = CensusClient()
        pop = client.get_acs_multi(
            variables=src["variables"],
            years=src["years"],
            geographies=src["geographies"],
            profile=src.get("profile"),
            states=src.get("states"),
        )
        log.info("Fetched %d raw rows from Census API", len(pop))

        area = fetch_land_area(tiger)

        pop = pop.merge(area[["geoid", "land_area_sqmi"]], on="geoid", how="left")
        pop["value"] = pop["total_pop"] / pop["land_area_sqmi"]
        pop["measure"] = "population_density"
        pop["moe"] = pd.NA

        result = pop[["geoid", "year", "measure", "value", "moe", "region_type"]]
        result = result.dropna(subset=["value"])

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
        log.error("Population density ingest failed: %s", e, exc_info=True)
        return RunResult(
            success=False,
            error=str(e),
            duration_sec=time.time() - t0,
        )


if __name__ == "__main__":
    result = run()
    if not result.success:
        raise SystemExit(1)
