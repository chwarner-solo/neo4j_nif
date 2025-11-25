# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-11-11

### Added

- **Full Row-to-Map Conversion**: Implemented the core feature of converting Neo4j query results into a list of Elixir maps, including support for nodes, relationships, and paths.
- **Comprehensive Type Support**: Handles conversion for all major Neo4j data types.
- **Automated Releases**: Set up a GitHub Actions workflow to test, pre-compile binaries for Linux (x86, ARM), macOS (Intel, ARM), and Windows, and publish to Hex.pm automatically on new version tags.
- **Robust Test Suite**: Added a full integration test suite and fixed all doctests to ensure code quality and stability.

### Notes

- This version currently depends on the `main` branch of the `neo4j-labs/neo4rs` repository to include necessary features that have not yet been part of a stable release.
