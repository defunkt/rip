module Rip
  class Parser
    def self.parse(content)
      new(content).parse
    end

    def initialize(content)
      @content = content
    end

    def parse(content = @content)
      content.map { |line| parse_package(line) }.compact
    end

    def parse_package(line)
      line = line.sub(/#.*/, '').strip

      return nil if line.empty?

      source, tweedle, version, *_ = line.split(' ')

      package = {}
      package[:source] = source

      if version || tweedle
        package[:version] = version ? "#{tweedle} #{version}" : tweedle
      end

      package
    end
  end
end
