# Changelog

## [0.1.0] - Unreleased

### Added
- Initial release
- `Ask::OpenTelemetry.install` — subscribes to all `.ask` events
- `Subscriber` — maps events to OpenTelemetry spans (llm.chat, llm.tool, llm.embedding, llm.image)
- Span attributes: llm.provider, llm.model, llm.input_tokens, llm.output_tokens, llm.duration_ms, llm.tool, llm.image.size
- Metadata forwarding: `Ask::Instrumentation.with_metadata` values set as `llm.metadata.*` attributes
- Railtie for automatic installation in Rails apps
- Full test suite with OpenTelemetry span verification
- README with backend examples (Langfuse, Datadog, Honeycomb)
