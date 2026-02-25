"""Config-driven pipeline loader.

Reads a pipeline.yaml and exposes the configuration as a typed object.
Individual repos define their pipeline.yaml; the sdc CLI and custom scripts
both use this to discover what to run.

Usage:
    from sdc_core.pipeline import load_pipeline

    config = load_pipeline("pipeline.yaml")
    print(config.name, config.sources)
"""

from __future__ import annotations

import pathlib
from dataclasses import dataclass, field

import yaml


@dataclass
class Source:
    """A data source definition from pipeline.yaml."""

    type: str  # "census_acs", "download", "custom"
    variables: list[str] = field(default_factory=list)
    years: list[int] = field(default_factory=list)
    states: list[str] = field(default_factory=list)
    geography: str = "block_group"
    url: str = ""
    extra: dict = field(default_factory=dict)

    @classmethod
    def from_dict(cls, d: dict) -> Source:
        known = {f.name for f in cls.__dataclass_fields__.values()}
        extra = {k: v for k, v in d.items() if k not in known}
        kwargs = {k: v for k, v in d.items() if k in known}
        kwargs["extra"] = extra
        return cls(**kwargs)


@dataclass
class Measure:
    """A measure definition from pipeline.yaml."""

    name: str
    numerator: str = ""
    denominator: str = ""
    aggregation: str = "mean"
    expression: str = ""
    extra: dict = field(default_factory=dict)

    @classmethod
    def from_dict(cls, d: dict) -> Measure:
        known = {f.name for f in cls.__dataclass_fields__.values()}
        extra = {k: v for k, v in d.items() if k not in known}
        kwargs = {k: v for k, v in d.items() if k in known}
        kwargs["extra"] = extra
        return cls(**kwargs)


@dataclass
class Output:
    """Output configuration from pipeline.yaml."""

    geographies: list[str] = field(default_factory=lambda: ["county", "tract", "block_group"])
    format: str = "csv_xz"


@dataclass
class PipelineConfig:
    """Parsed pipeline.yaml."""

    name: str
    version: str = "0.1.0"
    description: str = ""
    sources: list[Source] = field(default_factory=list)
    measures: list[Measure] = field(default_factory=list)
    output: Output = field(default_factory=Output)


def load_pipeline(path: str | pathlib.Path = "pipeline.yaml") -> PipelineConfig:
    """Load and parse a pipeline.yaml file.

    Parameters
    ----------
    path : str or Path
        Path to the YAML config file.

    Returns
    -------
    PipelineConfig
        Parsed configuration object.
    """
    path = pathlib.Path(path)
    if not path.exists():
        raise FileNotFoundError(f"Pipeline config not found: {path}")

    with open(path) as f:
        raw = yaml.safe_load(f)

    sources = [Source.from_dict(s) for s in raw.get("sources", [])]
    measures = [Measure.from_dict(m) for m in raw.get("measures", [])]

    output_raw = raw.get("output", {})
    output = Output(
        geographies=output_raw.get("geographies", ["county", "tract", "block_group"]),
        format=output_raw.get("format", "csv_xz"),
    )

    return PipelineConfig(
        name=raw["name"],
        version=raw.get("version", "0.1.0"),
        description=raw.get("description", ""),
        sources=sources,
        measures=measures,
        output=output,
    )
