# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-08

### Added
- Dynamic completion for local models (`run`, `rm`, `show`, `cp`, `push`).
- Real-time `curl`-based completion for remote model names and tags (`pull`).
- Graceful degradation to a popular models list and local base models when offline or `curl` is missing.
- 1-second timeout on network requests to prevent terminal freezing.

### Fixed
- Handled Bash's default colon word-splitting behavior by hooking into `__ltrim_colon_completions`. This allows flawless appending of model tags (e.g., `model:tag`) without duplicating prefixes.