## [0.1.3] - 2026-08-06

### Fixed
- `llm.duration_ms` was microsecond values labeled as milliseconds
  (`(event.duration * 1000)` — event.duration is already in ms; a 0.2s call
  showed 203052). Now `event.duration.round(2)` — real milliseconds.

## [0.1.2] - 2026-08-06

### Fixed
- `llm.input_tokens`/`llm.output_tokens` span attributes read from the nested
  `usage` payload hash (ask-agent enriches it after the call returns; the
  instrumenter shallow-copies the top-level payload). Top-level keys still
  work for other emitters. `llm.duration_ms` now reflects the real LLM call
  duration thanks to the ask-agent event fix.

## [0.1.1] - 2026-06-25

### Changed
- Railtie test (3 tests), subscriber install idempotency. Infrastructure: rubocop, overcommit, bin/setup, CI matrix, gemspec test.
# Changelog

## [0.1.0] - 2026-06-21

### Added
- Initial release
- `Ask::OpenTelemetry.install` — subscribes to all `.ask` events
- `Subscriber` — maps events to OpenTelemetry spans (llm.chat, llm.tool, llm.embedding, llm.image)
- Span attributes: llm.provider, llm.model, llm.input_tokens, llm.output_tokens, llm.duration_ms, llm.tool, llm.image.size
- Metadata forwarding: `Ask::Instrumentation.with_metadata` values set as `llm.metadata.*` attributes
- Railtie for automatic installation in Rails apps
- Full test suite with OpenTelemetry span verification
- README with backend examples (Langfuse, Datadog, Honeycomb)
