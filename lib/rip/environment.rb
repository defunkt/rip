module Rip
  class Environment
    def initialize(path)
      @path = path
    end

    def packages
      Rip::Parser.parse(File.read(@path), @path).map do |package|
        Rip::Package.from_hash(package)
      end
    end

    def conflicts?
      conflicts.any?
    end

    def conflicts
      hash = {}
      bad = []

      packages.each do |package|
        if hash[package.name]
          bad << hash[package.name]
          bad << package
        else
          hash[package.name] = package
        end
      end

      bad
    end
  end
end
