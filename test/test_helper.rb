$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"

# For OpenTelemetry test exporter support (opentelemetry-sdk is a runtime dep)
begin
  require "opentelemetry-sdk"
rescue LoadError => e
  warn "opentelemetry-sdk not available: #{e.message}"
end
