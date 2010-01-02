module Rip
  # Represents a deps.rip file
  class Deps
    include Enumerable

    def initialize(file)
      @file = File.expand_path(file)
    end

    def each(&block)
      deps.each(&block)
    end

    def deps
      @deps ||= deps!
    end

    def deps!
      File.read(@file).split("\n").map do |line|
        url, version = line.split(' ')
        Dep.new(url, version)
      end
    end
  end

  class Dep
    attr_accessor :url, :version
    def initialize(url, version = nil)
      @url = url
      @version = version
    end
  end
end
