# ask-opentelemetry

[![Gem Version](https://badge.fury.io/rb/ask-opentelemetry.svg)](https://badge.fury.io/rb/ask-opentelemetry)
[![CI](https://github.com/ask-rb/ask-opentelemetry/actions/workflows/ci.yml/badge.svg)](https://github.com/ask-rb/ask-opentelemetry/actions/workflows/ci.yml)

OpenTelemetry tracing for the ask-rb ecosystem. Subscribes to
`ask-instrumentation` events and creates OpenTelemetry spans for chat
completions, tool calls, embeddings, and image generation.

Works with any OpenTelemetry-compatible backend: Langfuse, Datadog, Honeycomb,
Jaeger, Arize Phoenix, and more.

## Installation

```ruby
gem "ask-opentelemetry"
gem "ask-instrumentation"
```

## Quick Start

```ruby
require "ask/open_telemetry"

# Subscribe to all ask events and create OpenTelemetry spans
Ask::OpenTelemetry.install
```

### In Rails

The Railtie auto-installs — no manual setup required:

```ruby
# Gemfile
gem "ask-opentelemetry"
gem "ask-instrumentation"
```

That's it. Spans are created automatically for every LLM operation.

## Spans Created

| Event | Span Name | Key Attributes |
|---|---|---|
| `chat.ask` | `llm.chat` | provider, model, input_tokens, output_tokens, duration_ms |
| `chat.stream.ask` | `llm.chat` | provider, model, input_tokens, output_tokens, duration_ms |
| `tool.ask` | `llm.tool` | provider, tool, tool_args |
| `embedding.ask` | `llm.embedding` | provider, model, input_tokens |
| `image.ask` | `llm.image` | provider, model, image.size, duration_ms |

### Standard Attributes

All spans include:

- `llm.provider` — The LLM provider (e.g., `openai`, `anthropic`)
- `llm.model` — The model identifier (e.g., `gpt-4`, `claude-3`)
- `llm.duration_ms` — The duration of the LLM operation in milliseconds
- `llm.input_tokens` — Input token count (when available)
- `llm.output_tokens` — Output token count (when available)

### Metadata Attributes

Any context set via `Ask::Instrumentation.with_metadata` is forwarded as
`llm.metadata.*` attributes:

```ruby
Ask::Instrumentation.with_metadata(user_id: 42, session_id: "abc") do
  # The resulting span has:
  #   llm.metadata.user_id = 42
  #   llm.metadata.session_id = "abc"
end
```

## Backend Examples

### Langfuse

[Langfuse](https://langfuse.com) provides LLM observability (cost tracking,
evaluations, prompt management) via OpenTelemetry.

**Using Langfuse Cloud:**

```ruby
require "ask/open_telemetry"
require "opentelemetry-sdk"
require "opentelemetry-exporter-otlp"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "my-app"
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: "https://cloud.langfuse.com/api/public/otel/v1/traces",
        headers: {
          "Authorization" => "Basic #{Base64.strict_encode64("#{LANGFUSE_PUBLIC_KEY}:#{LANGFUSE_SECRET_KEY}")}"
        }
      )
    )
  )
end

Ask::OpenTelemetry.install
```

**Using Langfuse Self-Hosted:**

```ruby
OpenTelemetry::SDK.configure do |c|
  c.service_name = "my-app"
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: "https://your-instance.langfuse.com/api/public/otel/v1/traces",
        headers: {
          "Authorization" => "Basic #{Base64.strict_encode64("#{LANGFUSE_PUBLIC_KEY}:#{LANGFUSE_SECRET_KEY}")}"
        }
      )
    )
  )
end
```

### Datadog

```ruby
require "ask/open_telemetry"
require "opentelemetry-sdk"
require "opentelemetry-exporter-otlp"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "my-app"
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: "https://otlp.datadoghq.com",
        headers: { "DD-API-KEY" => ENV["DD_API_KEY"] }
      )
    )
  )
end

Ask::OpenTelemetry.install
```

### Honeycomb

```ruby
require "ask/open_telemetry"
require "opentelemetry-sdk"
require "opentelemetry-exporter-otlp"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "my-app"
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: "https://api.honeycomb.io:443",
        headers: { "x-honeycomb-team" => ENV["HONEYCOMB_API_KEY"] }
      )
    )
  )
end

Ask::OpenTelemetry.install
```

## API

### `.install`

Subscribe to all `.ask` events and start creating spans. Idempotent — calling
multiple times only subscribes once.

```ruby
Ask::OpenTelemetry.install
```

## Development

```bash
git clone https://github.com/ask-rb/ask-opentelemetry.git
cd ask-opentelemetry
bundle install
bundle exec rake test
```

## License

MIT
