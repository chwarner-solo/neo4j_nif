# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial extraction from Grimoire project
- Connection support for Neo4j (including Aura with `bolt+s://`)
- Query execution framework
- Comprehensive type conversion (primitives, collections, graph types, spatial, temporal)
- Rust NIF using neo4rs 0.8
- Tokio runtime for async operations
- Resource-based connection management

### Known Issues
- Row API implementation incomplete - query results currently return empty maps
- This needs to be fixed before 0.1.0 release

## [0.1.0-dev] - 2024-11-11

### Status
- Extracted from Grimoire for isolated development
- Row API issue needs resolution
- Not yet published to Hex

[Unreleased]: https://github.com/chwarner-solo/neo4j_nif/compare/v0.1.0-dev...HEAD
[0.1.0-dev]: https://github.com/chwarner-solo/neo4j_nif/releases/tag/v0.1.0-dev
