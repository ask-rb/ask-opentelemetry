module Ask
  module OpenTelemetry
    # Subscribes to Ask::Instrumentation events and creates OpenTelemetry spans.
    #
    # Maps each event name to a span name:
    #   "chat.ask"        → "llm.chat"
    #   "chat.stream.ask" → "llm.chat"
    #   "tool.ask"        → "llm.tool"
    #   "embedding.ask"   → "llm.embedding"
    #   "image.ask"       → "llm.image"
    #
    # Forwards the event payload as span attributes under the +llm.*+ namespace
    # and merges in any metadata from +Ask::Instrumentation.current_metadata+.
    class Subscriber
      # Event name pattern → OpenTelemetry span name.
      SPAN_NAMES = {
        "chat.ask"        => "llm.chat",
        "chat.stream.ask" => "llm.chat",
        "tool.ask"        => "llm.tool",
        "embedding.ask"   => "llm.embedding",
        "image.ask"       => "llm.image"
      }.freeze

      # Invoked by +ActiveSupport::Notifications+ for each matching event.
      #
      # @param event [ActiveSupport::Notifications::Event] The instrumentation event
      def call(event)
        span_name = SPAN_NAMES[event.name]
        return unless span_name

        tracer.in_span(span_name, attributes: attributes_for(event)) do |span|
          # event.duration is already MILLISECONDS — multiplying by 1000
          # produced microsecond values labeled as ms (a 0.2s call showed
          # llm_duration_ms=203052).
          span.set_attribute("llm.duration_ms", event.duration.round(2))
        end
      end

      private

      def attributes_for(event)
        payload = event.payload

        attrs = {}

        # Core llm attributes
        attrs["llm.provider"]     = payload[:provider] if payload[:provider]
        attrs["llm.model"]        = payload[:model]    if payload[:model]

        # Token tracking (when available). Chat events emitted by ask-agent
        # enrich a shared nested +usage+ hash after the call returns (tokens
        # are only known then); other emitters pass them at the top level.
        usage = payload[:usage] || payload
        attrs["llm.input_tokens"]  = usage[:input_tokens]  if usage[:input_tokens]
        attrs["llm.output_tokens"] = usage[:output_tokens] if usage[:output_tokens]

        # Tool-specific
        attrs["llm.tool"]    = payload[:tool_name] if payload[:tool_name]
        attrs["llm.tool_args"] = payload[:tool_args] if payload[:tool_args] && payload[:tool_args].is_a?(String)

        # Image-specific
        attrs["llm.image.size"] = payload[:size] if payload[:size]

        # Forward all metadata from the instrumentation context
        Ask::Instrumentation.current_metadata.each do |key, value|
          next if key.to_s.start_with?("llm.") # don't clobber explicit llm attributes
          attrs["llm.metadata.#{key}"] = value
        end

        attrs
      end

      def tracer
        @tracer ||= ::OpenTelemetry.tracer_provider.tracer("ask-opentelemetry", Ask::OpenTelemetry::VERSION)
      end
    end
  end
end
