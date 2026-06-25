# frozen_string_literal: true

require_relative "../test_helper"

class RailtieTest < Minitest::Test
  def setup
    # Stub Rails for railtie loading
    unless defined?(::Rails)
      railtie = Class.new do
        def self.initializer(name) end
      end
      @_rails_stub = Module.new
      @_rails_stub.const_set(:Railtie, railtie)
      Object.const_set(:Rails, @_rails_stub)
    end
    require "ask/open_telemetry/railtie"
  end

  def teardown
    if @_rails_stub && Object.const_defined?(:Rails) && Object.const_get(:Rails) == @_rails_stub
      Object.send(:remove_const, :Rails)
    end
  end

  def test_railtie_is_defined
    assert Ask::OpenTelemetry::Railtie
  end

  def test_railtie_file_exists
    path = File.expand_path("../../lib/ask/open_telemetry/railtie.rb", __dir__)
    assert File.exist?(path)
  end

  def test_railtie_contains_initializer
    railtie_path = File.expand_path("../../lib/ask/open_telemetry/railtie.rb", __dir__)
    content = File.read(railtie_path)
    assert_includes content, "initializer"
    assert_includes content, "Ask::OpenTelemetry.install"
  end
end
