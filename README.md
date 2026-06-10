# ask-opentelemetry

[![Gem Version](https://badge.fury.io/rb/ask-opentelemetry.svg)](https://badge.fury.io/rb/ask-opentelemetry)

OpenTelemetry tracing for the ask-rb ecosystem. Subscribes to
`ask-instrumentation` events and creates OpenTelemetry spans.

Works with any OpenTelemetry-compatible backend: Datadog, Honeycomb, Langfuse,
Jaeger, Arize Phoenix, and more.

## Installation

```ruby
gem "ask-opentelemetry"
gem "ask-instrumentation"
```

## Quick Start

```ruby
require "ask/opentelemetry"

# Install the subscriber (creates spans from ask events)
Ask::OpenTelemetry.install
```

### In Rails

```ruby
# config/initializers/ask_opentelemetry.rb
Ask::OpenTelemetry.install
```

## Spans Created

| Event | Span Name | Attributes |
|---|---|---|
| `chat.ask` | `llm.chat` | provider, model, input/output tokens |
| `tool.ask` | `llm.tool` | tool name, args |
| `embedding.ask` | `llm.embedding` | provider, model |

## With Langfuse

Langfuse integrates with OpenTelemetry — just export spans to your Langfuse
endpoint and you get cost tracking, evaluations, and prompt management.

## License

MIT
