module Rip
  class Package < OpenStruct
    def self.parse(text)
      new(Parser.parse(text).first)
    end

    def to_s
      "#{name} (#{version})"
    end

    def name
      source.split('/').last.chomp('.git').chomp('.gem')
    end

    def dependencies
      Array(super).map { |dep| self.class.new(dep) }
    end
  end

  class Environment
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def packages
      Rip::Parser.parse(File.read(@path), @path).map do |hash|
        package_and_dependencies Package.new(hash)
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
