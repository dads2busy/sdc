"""Structured logging for SDC pipelines.

Provides a pre-configured logger that works well for both CLI and web contexts:
- CLI: human-readable format to stderr
- Web/API: can be reconfigured to JSON or captured programmatically

Usage:
    from sdc_core.log import get_logger

    log = get_logger("gender.ingest")
    log.info("Fetching ACS data", extra={"years": 15, "states": 3})
"""

from __future__ import annotations

import logging
import sys

_configured = False


def _setup_root():
    """Configure the sdc root logger once."""
    global _configured
    if _configured:
        return
    _configured = True

    root = logging.getLogger("sdc")
    root.setLevel(logging.INFO)

    if not root.handlers:
        handler = logging.StreamHandler(sys.stderr)
        handler.setFormatter(logging.Formatter(
            "%(asctime)s [%(name)s] %(levelname)s: %(message)s",
            datefmt="%H:%M:%S",
        ))
        root.addHandler(handler)


def get_logger(name: str) -> logging.Logger:
    """Get a logger under the 'sdc' namespace.

    Parameters
    ----------
    name : str
        Logger name, e.g. "gender.ingest". Will be prefixed with "sdc.".
    """
    _setup_root()
    return logging.getLogger(f"sdc.{name}")
