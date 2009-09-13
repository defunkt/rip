module Rip
  class GemfilePackage < Package
    handles 'Gemfile'

    class Environment
      attr_reader :dependencies
      attr_accessor :rubygems, :system_gems, :gem_path, :bindir

      def initialize
        @default_sources  = []
        @sources          = []
        @priority_sources = []
        @dependencies     = []
        @rubygems         = true
        @system_gems      = true
      end
    end

    def initialize(source, *args)
      package = Rip::Package.for('bundler')
      installer = Installer.new
      installer.install(package)

      require 'bundler'

      super
      @source = File.expand_path(source)
    end

    def exists?
      File.exists? source
    end

    def name
      source.split('/').last
    end

    def version
      nil
    end

    def actual_package
      nil
    end

    def meta_package?
      true
    end

    def cached?
      false
    end

    def dependency_installed(dependency, success = true)
      if !success
        ui.puts "rip: already installed #{dependency}"
      end
    end

    def fetch!
      FileUtils.rm_rf cache_path
      FileUtils.mkdir_p cache_path
      FileUtils.cp source, File.join(cache_path, name)
    end

    def unpack!
      fetch
    end

    def dependencies!
      if File.exists? filename = File.join(cache_path, name)
        environment = Environment.new
        builder = Bundler::Dsl.new(environment)
        builder.instance_eval(File.read(filename))

        environment.dependencies.map { |dependency|
          Package.for(dependency.name, dependency.version)
        }
      else
        []
      end
    end
  end
end
