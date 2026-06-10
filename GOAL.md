# ask-opentelemetry — OpenTelemetry Tracing for ask-rb

## Purpose

Tiny adapter that subscribes to `ask-instrumentation` events and creates
OpenTelemetry spans. Works with any OTel-compatible backend (Datadog,
Honeycomb, Langfuse, Jaeger, Arize Phoenix).

## Dependencies

- **Runtime:** `ask-instrumentation ~> 0.1`, `opentelemetry-api ~> 1.3`, `opentelemetry-sdk ~> 1.7`
- **Build/test:** minitest, rake

## How This Improves on opentelemetry-instrumentation-ruby_llm

| Old Gem | Our Gem |
|---|---|
| Tied to ruby_llm (patches RubyLLM::Chat) | Works with any provider via ask-instrumentation events |
| Only traces chat completions | Traces chat, tool calls, embeddings |
| Separate gem by thoughtbot (external maintainer) | Part of ask-rb ecosystem, co-evolves |

## Implementation Steps

### 1. Define Subscriber (`lib/ask/open_telemetry/subscriber.rb`)

A class that responds to `#call(event)` and creates spans:

```ruby
Ask::Instrumentation.subscribe(/\.ask$/, Subscriber.new)

# Subscriber#call maps event names to span names:
# "chat.ask"  → span "llm.chat" with attributes
# "tool.ask"  → span "llm.tool" with attributes
# "embedding.ask" → span "llm.embedding" with attributes
```

Span attributes:
- `llm.provider` — provider name
- `llm.model` — model name
- `llm.input_tokens` / `llm.output_tokens` (when available)
- `llm.tool` (for tool calls)
- Metadata from `Ask::Instrumentation.current_metadata` (user_id, session_id, etc.)

### 2. Define install method (`lib/ask/open_telemetry.rb`)

```ruby
Ask::OpenTelemetry.install  # subscribes to all .ask events
```

### 3. Railtie (optional)

Auto-install in Rails apps:
```ruby
module Ask::OpenTelemetry::Railtie
  # Automatically calls install in Rails
end
```

### 4. Tests

- Test subscriber creates spans with correct names
- Test attributes are set from event payload
- Test metadata is forwarded
- Test Railtie installs automatically (integration test)

### 5. Documentation

- README: quick start, span reference, backend examples
- How to use with Langfuse (most popular OTel backend for LLMs)

## Release Notes

v0.1.0: Core subscriber + install + Railtie + tests
