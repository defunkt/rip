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

      # check if already installed
      installed = graph.add_package(name, version)
      return if !installed

      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        fetch
        unpack(version)
        install_dependencies(graph)
        copy_files(graph)
      end

      graph.save
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
        graph.add_dependency(name, dependency.name, version)
        dependency.install(version, graph)
      end
    end

    def dependencies
      if File.exists? deps = File.join(path, 'deps.txt')
        File.readlines(deps).map { |line| line.split(' ') }
      else
        []
      end
    end

    def copy_files(graph)
      puts "installing #{name}..."

      package_lib = File.join(path, 'lib')
      package_bin = File.join(path, 'bin')

      dest = File.join(Rip.dir, Rip::Env.active)
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin')

      if File.exists? package_lib
        FileUtils.cp_r package_lib + '/.', dest_lib
        graph.add_files(name, Dir.glob(package_lib + '/*'))
      end

      if File.exists? package_bin
        FileUtils.cp_r package_bin + '/.', dest_bin
        graph.add_files(name, Dir.glob(package_bin + '/*'))
      end
    end

    def uninstall
      puts "can't uninstall yet"
    end

    def puts(msg)
      super "rip: #{msg}"
    end
  end
end
