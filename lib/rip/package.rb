require 'digest/md5'

module Rip
  class Package
    def initialize(target)
      @target = target.strip.chomp
    end

    def name
      @target.split('/').last.chomp('.git')
    end

    def package
      name + '-' + Digest::MD5.hexdigest(@target)
    end

    def path
      File.join(Rip.dir, 'rip-packages', package)
    end

    def install(version = nil, graph = nil)
      graph ||= DependencyGraph.new(Rip::Env.active)
      graph.add_package(name, version)

      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        fetch
        unpack(version)
        install_dependencies(graph)
        copy_files
      end
    end

    def fetch
      puts "fetching #{name}..."
      if File.exists? package
        Dir.chdir File.join(Dir.pwd, package) do
          `git fetch origin`
        end
      else
        `git clone #{@target} #{package}`
      end
    end

    def unpack(version = nil)
      puts "unpacking #{name}#{version ? ' ' + version : nil}..."
      Dir.chdir File.join(Dir.pwd, package) do
        `git reset --hard #{version || 'origin/master'}`
      end
    end

    def install_dependencies(graph)
      dependencies.each do |target, version, _|
        dependency = Package.new(target)
        if graph.add_dependency(name, dependency.name, version)
          dependency.install(version, graph)
        end
      end
    end

    def dependencies
      if File.exists? deps = File.join(path, 'deps.txt')
        File.readlines(deps).map { |line| line.split(' ') }
      else
        []
      end
    end

    def copy_files
      puts "installing #{name}..."
      package_rb = File.join(path, 'lib', "#{name}.rb")
      package_lib = File.join(path, 'lib', name)
      package_bin = File.join(path, 'bin', name)

      dest = File.join(Rip.dir, Rip::Env.active)
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin')

      if File.exists? package_rb
        FileUtils.cp package_rb, File.join(dest_lib, "#{name}.rb")
      end

      if File.exists? package_lib
        FileUtils.cp_r package_lib, File.join(dest_lib, name)
      end

      if File.exists? package_bin
        FileUtils.cp package_bin, dest_bin
      end
    end

    def uninstall
      puts "uninstalling..."

      dest = File.join(Rip.dir, Rip::Env.active)
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin')

      FileUtils.rm_rf File.join(dest_lib, "#{name}.rb") rescue nil
      FileUtils.rm_rf File.join(dest_lib, name) rescue nil
      FileUtils.rm_rf File.join(dest_bin, name) rescue nil

      puts "uninstalled #{name}"
    end

    def puts(msg)
      super "rip: #{msg}"
    end
  end
end
