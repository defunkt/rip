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

      args = line.split(' ')

      package = {}

      package[:source] = args[0]

      if args[1] && args[1] =~ /^\//
        package[:path]    = args[1]
        package[:version] = args[2] if args[2]
      elsif args[1] && args[2]
        package[:version] = "#{args[1]} #{args[2]}"
      else
        package[:version] = args[1] if args[1]
      end

      package
    end
  end
end
