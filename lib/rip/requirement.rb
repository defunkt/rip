module Rip
  class Requirement
    class Version
      include Comparable

      def initialize(version)
        @version = version

        if version =~ /^\d+\./
          @sequences  = version.scan(/\d+|[A-Za-z][0-9A-Za-z-]*$/).map { |s| s =~ /^\d+$/ ? s.to_i : s }
          @comparable = true
        else
          @sequences  = [version]
          @comparable = false
        end
      end

      def comparable?
        @comparable
      end

      def next
        return unless comparable?
        sequences = self.to_a
        sequences.pop if sequences.last.is_a?(String)
        sequences[-2] = sequences[-2].succ
        sequences[-1] = 0
        self.class.new(sequences.join('.'))
      end

      def eql?(other)
        self.class == other.class && self.to_s == other.to_s
      end

      def <=>(other)
        if comparable?
          to_a.zip(other.to_a).each do |a, b|
            if b.nil?
              return -1
            elsif a.nil?
              return 1
            elsif a.is_a?(String) && b.is_a?(Integer)
              return -1
            elsif a.is_a?(Integer) && b.is_a?(String)
              return 1
            elsif a == b
              next
            else
              return a <=> b
            end
          end
          0
        else
          to_s == other.to_s ? 0 : nil
        end
      end

      define_method :'~>' do |other|
        self >= other && self < other.next
      end

      def to_a
        @sequences.dup
      end

      def to_s
        @version.dup
      end

      def inspect
        "#<#{self.class} #{to_s}>"
      end
    end

    def initialize(*requirements)
      @requirements = []

      requirements.each do |requirement|
        (requirement || '').split(/,\s*/).each do |requirement|
          if requirement =~ /(~>|<=|>=|!=|<|>|=)?\s*(.+)/
            @requirements << [$1 || '=', Version.new($2)]
          else
            raise ArgumentError
          end
        end
      end

      @requirements.reject! { |tweedle, rv| tweedle == '>=' && rv.to_s == '0' }
    end

    def to_s
      @requirements.map { |tweedle, version| tweedle == '=' ? version : "#{tweedle}#{version}" }.join(',')
    end

    def any?
      @requirements.any?
    end

    def include?(version)
      @requirements.all? do |tweedle, rv|
        tweedle = '==' if tweedle == '='
        if ['==', '!=', '>', '<', '>=', '<=', '~>'].include?(tweedle)
          version.send(tweedle, rv)
        else
          raise ArgumentError
        end
      end
    end

    def inspect
      "#<#{self.class} #{any? ? to_s : '>=0'}>"
    end
  end
end
