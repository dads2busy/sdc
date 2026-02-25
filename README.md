# Social Data Commons (SDC)

Unified monorepo for Social Data Commons data pipelines.

## Structure

- `packages/sdc-core/` — Shared Python framework (Census API, I/O, geo aggregation, logging)
- `geographies/` — Crosswalks, entity definitions, geographic reference data
- `demographics/` — Demographic data pipelines (age, gender, race, language, veteran, etc.)
- `education/`, `health/`, `housing/`, etc. — Domain-specific data pipelines
- `meta/` — Infrastructure and utility repos

## Setup

```bash
uv sync
```

This creates a single `.venv` with `sdc-core` installed in editable mode.

## Usage

```bash
cd demographics/Gender
uv run sdc run ingest
```
