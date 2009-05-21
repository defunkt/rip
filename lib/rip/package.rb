require 'digest/md5'

#
# Want to write your own package?
#
# Check Rip::PackageAPI for the methods you need.
#

module Rip
  class Package
    include PackageAPI

    @@patterns = {}
    @@blocks = {}

    def self.handles(*patterns, &block)
      patterns.each do |pattern|
        @@patterns[pattern] = self
      end

      @@blocks[self] = block if block
    end

    def self.for(source, version = nil)
      source = source.strip.chomp

      handler = @@patterns.detect do |pattern, klass|
        source.match(pattern)
      end

      return handler[1].new(source, version) if handler

      handler = @@blocks.detect do |klass, block|
        block.call(source)
      end

      handler[0].new(source, version) if handler
    end

    alias_method :to_s, :name
    attr_reader :source

    def initialize(source, version = nil)
      @source = source.strip.chomp
      @version = nil
    end

    def cache_name
      @cache_name ||= name + '-' + Digest::MD5.hexdigest(@source)
    end

    def cache_path
      @cache_path ||= File.join(Rip.dir, 'rip-packages', cache_name)
    end

    def installed?(version = nil)
      graph = DependencyManager.new

      if version
        graph.package_version(name) == version
      else
        graph.installed?(name)
      end
    end

    def install(graph = nil, parent = nil)
      graph ||= DependencyManager.new

      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        installed = graph.add_package(name, version, parent)
        return if !installed

        fetch
        unpack
        install_dependencies(graph)
        run_install_hook
        copy_files(graph)
      end
    end

    def install_dependencies(graph)
      dependencies.each do |source, version, _|
        dependency = Package.for(source, version)
        dependency.install(graph, name)
      end
    end

    def dependencies
      if File.exists? deps = File.join(cache_path, 'deps.txt')
        File.readlines(deps).map { |line| line.split(' ') }
      else
        []
      end
    end

    def run_install_hook
      return unless File.exists? File.join(cache_path, 'Rakefile')
      Dir.chdir cache_path do
        puts "running install hook for #{name}"
        system "rake -s rip:install >& /dev/null"
      end
    end

    def copy_files(graph)
      puts "installing #{name}..."

      package_lib = File.join(cache_path, 'lib')
      package_bin = File.join(cache_path, 'bin')

      dest = File.join(Rip.dir, Rip::Env.active)
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin')

      if File.exists? package_lib
        FileUtils.cp_r package_lib + '/.', dest_lib

        files_added = Dir.glob(package_lib + '/*').map do |file|
          File.join(dest_lib, File.basename(file))
        end

        graph.add_files(name, files_added)
      end

      if File.exists? package_bin
        FileUtils.cp_r package_bin + '/.', dest_bin

        files_added = Dir.glob(package_bin + '/*').map do |file|
          File.join(dest_bin, File.basename(file))
        end

        graph.add_files(name, files_added)
      end
    end

    def uninstall(remove_dependencies = false)
      graph = DependencyManager.new
      packages = [name]

      if remove_dependencies
        packages.concat graph.packages_that_depend_on(name)
      end

      packages.each do |package|
        puts "uninstalling #{package}"

        graph.files(package).each do |file|
          FileUtils.rm_rf file
        end

        graph.remove_package(package)
      end
    end

    def puts(msg)
      super "rip: #{msg}"
    end
  end
end
