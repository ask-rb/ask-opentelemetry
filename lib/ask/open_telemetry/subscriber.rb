module Ask
  module OpenTelemetry
    class Subscriber
      def call(event)
        case event.name
        when "chat.ask"
          create_span("llm.chat", event) do |span|
            span.set_attribute("llm.provider", event.payload[:provider])
            span.set_attribute("llm.model", event.payload[:model])
            span.set_attribute("llm.input_tokens", event.payload[:input_tokens]) if event.payload[:input_tokens]
            span.set_attribute("llm.output_tokens", event.payload[:output_tokens]) if event.payload[:output_tokens]
          end
        when "tool.ask"
          create_span("llm.tool", event) do |span|
            span.set_attribute("llm.tool", event.payload[:tool_name])
          end
        when "embedding.ask"
          create_span("llm.embedding", event) do |span|
            span.set_attribute("llm.provider", event.payload[:provider])
            span.set_attribute("llm.model", event.payload[:model])
          end
        end
      end

      private

      def create_span(name, event)
        tracer.in_span(name, attributes: {}) do |span|
          yield span
        end
      end

      def tracer
        @tracer ||= OpenTelemetry.tracer_provider.tracer("ask-opentelemetry", Ask::OpenTelemetry::VERSION)
      end
    end
  end
end
