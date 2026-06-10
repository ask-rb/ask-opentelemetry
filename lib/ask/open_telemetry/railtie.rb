module Ask
  module OpenTelemetry
    # Rails Railtie that auto-installs ask-opentelemetry in any Rails app.
    #
    # Automatically calls +Ask::OpenTelemetry.install+ during Rails
    # initialization so LLM operations are traced without manual setup.
    #
    # @example
    #   # No configuration needed — the railtie auto-installs.
    #   # Bundler loads the gem, the railtie hooks into Rails init.
    class Railtie < ::Rails::Railtie
      initializer "ask.opentelemetry" do
        Ask::OpenTelemetry.install
      end
    end
  end
end
