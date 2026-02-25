"""CLI entry point for SDC pipelines.

Usage:
    sdc run ingest           # run the ingest step
    sdc run prepare          # run the prepare step
    sdc run all              # run ingest then prepare
    sdc run all --year 2022  # override year
    sdc info                 # show pipeline config
"""

from __future__ import annotations

import importlib
import pathlib
import sys

import click

from sdc_core.pipeline import load_pipeline


@click.group()
def main():
    """SDC dataset pipeline runner."""
    pass


@main.command()
@click.argument("step", type=click.Choice(["ingest", "prepare", "all"]))
@click.option("--config", "-c", default="pipeline.yaml", help="Path to pipeline.yaml")
@click.option("--year", "-y", type=int, multiple=True, help="Override year(s)")
@click.option("--state", "-s", multiple=True, help="Override state(s)")
def run(step: str, config: str, year: tuple[int, ...], state: tuple[str, ...]):
    """Run a pipeline step (ingest, prepare, or all)."""
    pipeline = load_pipeline(config)
    click.echo(f"Pipeline: {pipeline.name} v{pipeline.version}")

    # Apply CLI overrides to sources
    if year:
        for source in pipeline.sources:
            source.years = list(year)
    if state:
        for source in pipeline.sources:
            source.states = list(state)

    # Import and run the local code/ modules
    code_dir = pathlib.Path("code")
    if code_dir.is_dir():
        sys.path.insert(0, str(code_dir))

    steps = ["ingest", "prepare"] if step == "all" else [step]

    for s in steps:
        click.echo(f"\n--- Running: {s} ---")
        try:
            mod = importlib.import_module(s)
        except ModuleNotFoundError:
            click.echo(f"No code/{s}.py found, skipping.")
            continue

        if hasattr(mod, "run"):
            mod.run(pipeline)
        elif hasattr(mod, s):
            getattr(mod, s)(pipeline)
        else:
            click.echo(f"Warning: code/{s}.py has no run() or {s}() function.")


@main.command()
@click.option("--config", "-c", default="pipeline.yaml", help="Path to pipeline.yaml")
def info(config: str):
    """Display pipeline configuration."""
    pipeline = load_pipeline(config)
    click.echo(f"Name:        {pipeline.name}")
    click.echo(f"Version:     {pipeline.version}")
    click.echo(f"Description: {pipeline.description}")
    click.echo(f"Sources:     {len(pipeline.sources)}")
    for i, src in enumerate(pipeline.sources):
        click.echo(f"  [{i}] type={src.type} vars={len(src.variables)} "
                    f"years={src.years} states={src.states} geo={src.geography}")
    click.echo(f"Measures:    {len(pipeline.measures)}")
    for m in pipeline.measures:
        click.echo(f"  - {m.name} ({m.aggregation})")
    click.echo(f"Output:      {pipeline.output.geographies} ({pipeline.output.format})")
