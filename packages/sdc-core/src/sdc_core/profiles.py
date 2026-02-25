"""Geography profiles for common multi-state/county regions.

A profile is a named shorthand that expands to a list of states (and
optionally specific counties). Use profiles in pipeline.yaml instead of
listing individual states:

    sources:
      - type: census_acs
        profile: NCR
        # equivalent to states: [VA, MD, DC] with county filtering

Profiles are extensible — add new ones via register_profile().

Usage:
    from sdc_core.profiles import resolve_profile, PROFILES

    states, counties = resolve_profile("NCR")
    # states = ["VA", "MD", "DC"]
    # counties = {"VA": ["059", "600", ...], "MD": ["021", "031", ...], "DC": ["001"]}
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class GeoProfile:
    """A named geography profile."""

    name: str
    description: str
    states: list[str]
    # Optional county-level filtering: state abbreviation → list of county FIPS (3-digit).
    # If empty, all counties in the state are included.
    counties: dict[str, list[str]] = field(default_factory=dict)


# Built-in profiles
PROFILES: dict[str, GeoProfile] = {}


def register_profile(profile: GeoProfile) -> None:
    """Register a geography profile by name."""
    PROFILES[profile.name.upper()] = profile


def resolve_profile(name: str) -> GeoProfile:
    """Look up a profile by name (case-insensitive)."""
    key = name.upper()
    if key not in PROFILES:
        available = ", ".join(sorted(PROFILES.keys()))
        raise ValueError(f"Unknown profile: {name!r}. Available: {available}")
    return PROFILES[key]


def resolve_states(source_config) -> list[str]:
    """Extract the state list from a source config, resolving profiles if present.

    Accepts either a Source dataclass or a dict with 'profile' and/or 'states' keys.
    """
    if hasattr(source_config, "extra"):
        profile_name = source_config.extra.get("profile")
        explicit_states = source_config.states
    elif isinstance(source_config, dict):
        profile_name = source_config.get("profile")
        explicit_states = source_config.get("states", [])
    else:
        return []

    if profile_name:
        profile = resolve_profile(profile_name)
        return profile.states
    return explicit_states


# ---- Built-in profile definitions ----

register_profile(GeoProfile(
    name="VA",
    description="Virginia (all counties)",
    states=["VA"],
))

register_profile(GeoProfile(
    name="DC",
    description="District of Columbia",
    states=["DC"],
))

register_profile(GeoProfile(
    name="MD",
    description="Maryland (all counties)",
    states=["MD"],
))

register_profile(GeoProfile(
    name="NCR",
    description="National Capital Region (VA, MD, DC)",
    states=["VA", "MD", "DC"],
    counties={
        "VA": ["059", "600", "610", "107", "013", "510", "683", "685", "153"],
        "MD": ["021", "031", "033", "017"],
        "DC": ["001"],
    },
))

register_profile(GeoProfile(
    name="VA_NCR",
    description="Virginia plus full NCR states (VA, MD, DC — all counties)",
    states=["VA", "MD", "DC"],
))
