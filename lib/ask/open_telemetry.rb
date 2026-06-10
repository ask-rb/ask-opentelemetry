require "ask/instrumentation"
require "opentelemetry-api"
require_relative "open_telemetry/version"

module Ask
  module OpenTelemetry
    autoload :Subscriber, "ask/open_telemetry/subscriber"
    autoload :Railtie, "ask/open_telemetry/railtie" if defined?(Rails::Railtie)

    class << self
      def install
        Ask::Instrumentation.subscribe(/\.ask$/, Subscriber.new)
      end
    end
  end
end
