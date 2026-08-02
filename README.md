# ask-opentelemetry

[![Gem Version](https://badge.fury.io/rb/ask-opentelemetry.svg)](https://badge.fury.io/rb/ask-opentelemetry)
[![CI](https://github.com/ask-rb/ask-opentelemetry/actions/workflows/ci.yml/badge.svg)](https://github.com/ask-rb/ask-opentelemetry/actions/workflows/ci.yml)

OpenTelemetry tracing for the ask-rb ecosystem. Subscribes to
`ask-instrumentation` events and creates OpenTelemetry spans for chat
completions, tool calls, embeddings, and image generation. Backend-agnostic:
the exporter is configured with the standard OpenTelemetry SDK, so spans go
to any OpenTelemetry-compatible backend (Langfuse, Datadog, Honeycomb, Jaeger,
Arize Phoenix, and more).

## Installation

```ruby
gem "ask-opentelemetry"
gem "ask-instrumentation"
```

## Quick Start

```ruby
require "ask/open_telemetry"

Ask::OpenTelemetry.install
```

That's it. Every `Ask::Instrumentation` event is now wrapped in a span. The
call is idempotent; subsequent calls are no-ops.

In a Rails app, the Railtie calls `Ask::OpenTelemetry.install` automatically:
no manual setup required.

## Spans Created

| Event | Span |
|---|---|
| `chat.ask`, `chat.stream.ask` | `llm.chat` |
| `tool.ask` | `llm.tool` |
| `embedding.ask` | `llm.embedding` |
| `image.ask` | `llm.image` |

Span attributes use the `llm.*` namespace: `llm.provider`, `llm.model`,
`llm.input_tokens`, `llm.output_tokens`, `llm.duration_ms`, `llm.tool`,
`llm.tool_args`, and `llm.image.size` when present. Any context set via
`Ask::Instrumentation.with_metadata` is forwarded as `llm.metadata.*`
attributes.

## Configuration

`Ask::OpenTelemetry.install` is the entire public API; there is no exporter
configuration on the gem itself. Configure the exporter once with the standard
OpenTelemetry SDK before calling `install`:

```ruby
require "opentelemetry-sdk"
require "opentelemetry-exporter-otlp"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "my-app"
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(endpoint: "https://otlp.example.com")
    )
  )
end

Ask::OpenTelemetry.install
```

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs.
https://ask-rb.github.io/ask-docs/production/opentelemetry covers
ask-opentelemetry in depth, including per-backend setup examples. API
reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

bundle install
bundle exec rake test

## License

MIT
