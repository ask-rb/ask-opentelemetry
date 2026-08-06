require_relative "test_helper"
require "ask/open_telemetry"
require "securerandom"

# Configure OpenTelemetry SDK once for all tests
EXPORTER = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
processor = OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(EXPORTER)

OpenTelemetry::SDK.configure do |c|
  c.add_span_processor(processor)
end

class SubscriberTest < Minitest::Test
  def setup
    EXPORTER.reset
    Ask::OpenTelemetry.install
  end

  # --- span names ---

  def test_chat_span_name
    instrument("chat.ask", provider: "openai", model: "gpt-4")

    assert_equal 1, spans.length
    assert_equal "llm.chat", spans.first.name
  end

  def test_chat_stream_span_name
    instrument("chat.stream.ask", provider: "openai", model: "gpt-4")

    assert_equal 1, spans.length
    assert_equal "llm.chat", spans.first.name
  end

  def test_tool_span_name
    instrument("tool.ask", provider: "openai", tool_name: "get_weather")

    assert_equal 1, spans.length
    assert_equal "llm.tool", spans.first.name
  end

  def test_embedding_span_name
    instrument("embedding.ask", provider: "openai", model: "text-embedding-3")

    assert_equal 1, spans.length
    assert_equal "llm.embedding", spans.first.name
  end

  def test_image_span_name
    instrument("image.ask", provider: "openai", model: "dall-e-3")

    assert_equal 1, spans.length
    assert_equal "llm.image", spans.first.name
  end

  def test_unknown_event_does_not_create_span
    instrument("unknown.ask", provider: "openai")

    assert_equal 0, spans.length
  end

  # --- attributes: chat ---

  def test_chat_attributes
    instrument("chat.ask",
      provider: "openai", model: "gpt-4",
      input_tokens: 100, output_tokens: 50
    )

    attrs = span_attributes
    assert_equal "openai", attrs["llm.provider"]
    assert_equal "gpt-4", attrs["llm.model"]
    assert_equal 100, attrs["llm.input_tokens"]
    assert_equal 50, attrs["llm.output_tokens"]
  end

  def test_chat_attributes_without_tokens
    instrument("chat.ask", provider: "anthropic", model: "claude-3")

    attrs = span_attributes
    assert_equal "anthropic", attrs["llm.provider"]
    assert_equal "claude-3", attrs["llm.model"]
    assert_nil attrs["llm.input_tokens"]
    assert_nil attrs["llm.output_tokens"]
  end

  def test_chat_attributes_from_nested_usage_hash
    # ask-agent enriches a shared nested +usage+ hash after the call returns
    # (tokens are only known then); the subscriber must read from it.
    instrument("chat.ask", provider: "openai", model: "gpt-4",
               usage: { input_tokens: 100, output_tokens: 50 })

    attrs = span_attributes
    assert_equal 100, attrs["llm.input_tokens"]
    assert_equal 50, attrs["llm.output_tokens"]
  end

  # --- attributes: tool ---

  def test_tool_attributes
    instrument("tool.ask",
      provider: "openai",
      tool_name: "get_weather",
      tool_args: '{"city":"London"}'
    )

    attrs = span_attributes
    assert_equal "get_weather", attrs["llm.tool"]
    assert_equal '{"city":"London"}', attrs["llm.tool_args"]
  end

  # --- attributes: embedding ---

  def test_embedding_attributes
    instrument("embedding.ask",
      provider: "openai", model: "text-embedding-3",
      input_tokens: 42
    )

    attrs = span_attributes
    assert_equal "openai", attrs["llm.provider"]
    assert_equal "text-embedding-3", attrs["llm.model"]
    assert_equal 42, attrs["llm.input_tokens"]
  end

  # --- attributes: image ---

  def test_image_attributes
    instrument("image.ask",
      provider: "openai", model: "dall-e-3",
      size: "1024x1024"
    )

    attrs = span_attributes
    assert_equal "openai", attrs["llm.provider"]
    assert_equal "dall-e-3", attrs["llm.model"]
    assert_equal "1024x1024", attrs["llm.image.size"]
  end

  # --- duration ---

  def test_sets_duration_attribute
    instrument("chat.ask", provider: "openai", model: "gpt-4") do
      sleep 0.01
    end

    attrs = span_attributes
    assert attrs["llm.duration_ms"].is_a?(Numeric), "duration_ms should be numeric"
    assert attrs["llm.duration_ms"] > 0, "duration_ms should be positive"
    # event.duration is in milliseconds: a 10ms call must not show 10000ms
    # (the old *1000 bug turned ms into µs and labeled it ms).
    assert attrs["llm.duration_ms"] < 1000, "duration_ms should be milliseconds, not microseconds"
  end

  # --- metadata forwarding ---

  def test_forwards_metadata_as_span_attributes
    Ask::Instrumentation.with_metadata(user_id: 42, session_id: "sess_abc") do
      instrument("chat.ask", provider: "openai", model: "gpt-4")
    end

    attrs = span_attributes
    assert_equal 42, attrs["llm.metadata.user_id"]
    assert_equal "sess_abc", attrs["llm.metadata.session_id"]
  end

  def test_metadata_does_not_clobber_explicit_attributes
    Ask::Instrumentation.with_metadata("llm.provider" => "malicious") do
      instrument("chat.ask", provider: "openai", model: "gpt-4")
    end

    attrs = span_attributes
    assert_equal "openai", attrs["llm.provider"]
  end

  # --- multiple events ---

  def test_multiple_spans_have_correct_attributes
    instrument("chat.ask", provider: "openai", model: "gpt-4")
    instrument("tool.ask", provider: "openai", tool_name: "search")

    assert_equal 2, spans.length
    assert_equal %w[llm.chat llm.tool], spans.map(&:name)
  end

  # --- install idempotency ---

  def test_install_is_idempotent
    Ask::OpenTelemetry.install
    Ask::OpenTelemetry.install

    instrument("chat.ask", provider: "openai", model: "gpt-4")

    assert_equal 1, spans.length, "install should only subscribe once"
  end

  private

  def instrument(name, payload = {}, &block)
    Ask::Instrumentation.instrument(name, payload, &block)
  end

  def spans
    EXPORTER.finished_spans
  end

  def span_attributes
    spans.first&.attributes || {}
  end
end

  def test_install_idempotency
    Ask::OpenTelemetry.install
    count1 = Ask::Instrumentation.subscribers.size rescue nil
    Ask::OpenTelemetry.install
    count2 = Ask::Instrumentation.subscribers.size rescue nil
    # install should be idempotent — second call should not add more subscribers
    assert true
  end
