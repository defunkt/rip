module Rip
  class Package < OpenStruct
    def to_s
      "#{source} (#{version})"
    end

    def name
      if source =~ /git/
        source.split('/').last.chomp('.git')
      else
        source
      end
    end
  end

  class Environment
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def packages
      Rip::Parser.parse(File.read(@path), @path).map do |hash|
        Package.new(hash)
      end.flatten
    end

    def package_and_dependencies(package)
      packages = []
      packages << package
      package.dependencies.each do |dep|
        packages.concat package_and_dependencies(dep)
      end

      packages
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
