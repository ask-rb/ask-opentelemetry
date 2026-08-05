require "ask/instrumentation"
require "opentelemetry-api"
require_relative "open_telemetry/version"

# Rails discovers gem railties only when they are required, so load the
# railtie from the entry file once Rails itself is on the stack (the
# documented pattern: "require my_gem/railtie if defined?(Rails::Railtie)").
require_relative "open_telemetry/railtie" if defined?(Rails::Railtie)

module Ask
  # OpenTelemetry tracing for the ask-rb ecosystem.
  #
  # Subscribes to +Ask::Instrumentation+ events and creates OpenTelemetry spans
  # for chat completions, tool calls, embeddings, and image generation.
  #
  # == Usage
  #
  #   Ask::OpenTelemetry.install
  #
  # In a Rails app the railtie installs automatically — no manual call needed.
  module OpenTelemetry
    autoload :Subscriber, "ask/open_telemetry/subscriber"
    autoload :Railtie,    "ask/open_telemetry/railtie"

    class << self
      # Subscribe to all ask events and start creating spans.
      #
      # Once called, every +Ask::Instrumentation+ event will be wrapped in an
      # OpenTelemetry span. Safe to call multiple times — subsequent calls are
      # no-ops.
      def install
        return if @installed

        Ask::Instrumentation.subscribe(/\.ask$/, Subscriber.new)
        @installed = true
      end
    end
  end
end
