"""sdc-core: Shared framework for Social Data Commons dataset pipelines."""

__version__ = "0.1.0"

from sdc_core.census import CensusClient
from sdc_core.geo import aggregate_to_geographies, aggregate_up, aggregate_with_crosswalk
from sdc_core.io import read_data, write_data
from sdc_core.pipeline import load_pipeline
from sdc_core.profiles import resolve_profile, resolve_states, register_profile
from sdc_core.log import get_logger
from sdc_core.result import RunResult

__all__ = [
    "CensusClient",
    "RunResult",
    "aggregate_to_geographies",
    "aggregate_up",
    "aggregate_with_crosswalk",
    "get_logger",
    "load_pipeline",
    "read_data",
    "register_profile",
    "resolve_profile",
    "resolve_states",
    "write_data",
]
