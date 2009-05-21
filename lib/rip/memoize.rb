# you know, for kids
module Rip
  module Memoize
    def self.included(base)
      base.extend self
    end

    def memoize(method)
      @memoized ||= {}
      @memoized[method] = true
    end

    def method_added(method)
      @memoized ||= {}
      return unless @memoized.delete(method)

      real_name = "__memoized_#{method}"
      alias_method real_name, method

      if self.instance_method(method).arity == 0
        define_method method do
          if instance_variable_defined? ivar = "@#{method}"
            instance_variable_get ivar
          else
            instance_variable_set ivar, send(real_name)
          end
        end
      else
        define_method method do |*args|
          @memoize_cache ||= {}
          key = [method, args].hash

          if @memoize_cache.has_key?(key)
            @memoize_cache[key]
          else
            @memoize_cache[key] = send(real_name, *args)
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  require 'test/unit'

  class TestMemoize < Test::Unit::TestCase
    class Encoder
      include Rip::Memoize

      attr_reader :encodes
      def initialize
        @encodes = 0
      end

      memoize :encode
      def encode(name)
        @encodes += 1

        parts = name.split(//).map do |letter|
          letter[0]
        end

        parts.join('/')
      end

      memoize :simple
      def simple
        @encodes += 1
        1 + 1
      end
    end

    def setup
      @obj = Encoder.new
    end

    def test_properly_executes_methods
      @obj.encode('chris')
      assert_equal '99/104/114/105/115', @obj.encode('chris')
    end

    def test_memoizes_method
      @obj.encode('chris')
      @obj.encode('chris')
      @obj.encode('chris')

      assert_equal 1, @obj.encodes
    end

    def test_memoizes_multiple_methods
      @obj.encode('chris')
      @obj.encode('bob')
      @obj.encode('chris')
      @obj.encode('bob')

      assert_equal 2, @obj.encodes
    end

    def test_memoizes_argless_methods
      @obj.simple
      @obj.simple
      assert_equal 1, @obj.encodes
    end

    def test_uses_simple_ivar_for_argless_methods
      @obj.simple
      assert_equal 2, @obj.instance_variable_get(:@simple)
    end
  end
end
