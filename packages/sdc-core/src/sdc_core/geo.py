"""Geographic utilities for GEOID manipulation and multi-level aggregation.

The core pattern across SDC pipelines: start with block-group-level data
and roll up to tract and county levels using GEOID string slicing.

Usage:
    from sdc_core.geo import aggregate_to_geographies

    df = aggregate_to_geographies(
        block_group_df,
        measure="perc_hh_with_broadband",
        method="mean",
    )
"""

from __future__ import annotations

from typing import Literal

import pandas as pd

# GEOID lengths by geography level
GEOID_LENGTHS: dict[str, int] = {
    "county": 5,
    "tract": 11,
    "block_group": 12,
}

# Reverse lookup
LENGTH_TO_GEO: dict[int, str] = {v: k for k, v in GEOID_LENGTHS.items()}

AggMethod = Literal["mean", "sum", "median", "min", "max"]


def geoid_to_county(geoid: pd.Series) -> pd.Series:
    """Extract county FIPS (first 5 chars) from a GEOID series."""
    return geoid.str[:5]


def geoid_to_tract(geoid: pd.Series) -> pd.Series:
    """Extract tract FIPS (first 11 chars) from a GEOID series."""
    return geoid.str[:11]


def geoid_level(geoid: pd.Series) -> str:
    """Infer the geography level from GEOID string length."""
    length = geoid.str.len().mode().iloc[0]
    if length not in LENGTH_TO_GEO:
        raise ValueError(f"Cannot infer geography from GEOID length {length}")
    return LENGTH_TO_GEO[length]


def aggregate_up(
    df: pd.DataFrame,
    target_geo: str,
    method: AggMethod = "mean",
    value_col: str = "value",
) -> pd.DataFrame:
    """Aggregate a DataFrame to a higher geography level.

    Parameters
    ----------
    df : pd.DataFrame
        Must have columns: geoid, year, value (at minimum).
    target_geo : str
        Target geography: "tract" or "county".
    method : str
        Aggregation method for the value column.
    value_col : str
        Column to aggregate.

    Returns
    -------
    pd.DataFrame
        Aggregated DataFrame with geoid, year, measure, value, region_type.
    """
    target_length = GEOID_LENGTHS[target_geo]
    result = df.copy()
    result["_target_geoid"] = result["geoid"].str[:target_length]

    group_cols = ["_target_geoid", "year"]
    if "measure" in result.columns:
        group_cols.append("measure")

    agg = result.groupby(group_cols)[value_col].agg(method).reset_index()
    agg = agg.rename(columns={"_target_geoid": "geoid"})
    agg["region_type"] = target_geo
    return agg


def aggregate_to_geographies(
    df: pd.DataFrame,
    measure: str,
    method: AggMethod = "mean",
    levels: list[str] | None = None,
    value_col: str = "value",
) -> pd.DataFrame:
    """Aggregate block-group data to multiple geography levels and combine.

    This is the standard SDC pattern: take block-group-level data and produce
    a single DataFrame with county, tract, and block group rows.

    Parameters
    ----------
    df : pd.DataFrame
        Block-group-level data with columns: geoid, year, value.
    measure : str
        Measure name to set in the output.
    method : str
        Aggregation method ("mean" for percentages, "sum" for counts).
    levels : list[str] or None
        Geography levels to include. Default: ["county", "tract", "block_group"].
    value_col : str
        Column to aggregate.

    Returns
    -------
    pd.DataFrame
        Combined DataFrame with all geography levels, sorted by geoid.
    """
    if levels is None:
        levels = ["county", "tract", "block_group"]

    source_level = geoid_level(df["geoid"])
    parts = []

    for level in levels:
        if level == source_level:
            part = df.copy()
            part["region_type"] = level
        else:
            part = aggregate_up(df, level, method=method, value_col=value_col)

        part["measure"] = measure
        parts.append(part)

    combined = pd.concat(parts, ignore_index=True)
    return combined.sort_values(["region_type", "geoid", "year"]).reset_index(drop=True)


def aggregate_with_crosswalk(
    df: pd.DataFrame,
    crosswalk: pd.DataFrame,
    source_col: str,
    target_col: str,
    method: AggMethod = "mean",
    value_col: str = "value",
    target_region_type: str | None = None,
) -> pd.DataFrame:
    """Aggregate data to a custom geography using a crosswalk table.

    Used for geographies that can't be derived from GEOID string slicing,
    such as health districts, supervisor districts, or planning districts.

    Parameters
    ----------
    df : pd.DataFrame
        Source data with geoid, year, measure, value columns.
    crosswalk : pd.DataFrame
        Mapping table with at least source_col and target_col columns.
    source_col : str
        Column in crosswalk matching df's geoid (e.g., "ct_geoid").
    target_col : str
        Column in crosswalk for target geography (e.g., "hd_geoid").
    method : str
        Aggregation method.
    value_col : str
        Column to aggregate.
    target_region_type : str or None
        Region type label for the output. If None, uses target_col.

    Returns
    -------
    pd.DataFrame
        Aggregated data at the target geography level.
    """
    merged = df.merge(
        crosswalk[[source_col, target_col]].drop_duplicates(),
        left_on="geoid",
        right_on=source_col,
        how="inner",
    )

    group_cols = [target_col, "year"]
    if "measure" in merged.columns:
        group_cols.append("measure")

    agg = merged.groupby(group_cols)[value_col].agg(method).reset_index()
    agg = agg.rename(columns={target_col: "geoid"})
    agg["region_type"] = target_region_type or target_col

    # Drop the source join column if it's still there
    if source_col in agg.columns and source_col != "geoid":
        agg = agg.drop(columns=[source_col])

    return agg
