module Rip
  class Installer
    include Memoize

    memoize :graph
    def graph
      PackageManager.new
    end

    def install(package, parent = nil)
      if !package.exists?
        abort "#{package.name} not found at #{package.source}"
      end

      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        installed = graph.add_package(package, parent)
        return if !installed

        begin
          package.fetch
          package.unpack
          install_dependencies(package)
          run_install_hook(package)
          copy_files(package)
        rescue => e
          uninstall(package, true)
          raise e
        end
      end
    end

    def install_dependencies(package)
      package.dependencies.each do |dependency|
        install(dependency, package)
      end
    end

    def run_install_hook(package)
      return unless File.exists? File.join(package.cache_path, 'Rakefile')

      Dir.chdir package.cache_path do
        puts "running install hook for #{package.name}"
        system "rake -s rip:install >& /dev/null"
      end
    end

    def copy_files(package)
      puts "installing #{package.name}..."

      package_lib = File.join(package.cache_path, 'lib')
      package_bin = File.join(package.cache_path, 'bin')

      dest = File.join(Rip.dir, Rip::Env.active)
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin')

      if File.exists? package_lib
        FileUtils.cp_r package_lib + '/.', dest_lib
      end

      if File.exists? package_bin
        FileUtils.cp_r package_bin + '/.', dest_bin
      end
    end

    def uninstall(package, remove_dependencies = false)
      packages = [package]

      if remove_dependencies
        packages.concat graph.packages_that_depend_on(package.name)
      end

      Dir.chdir File.join(Rip.dir, Rip::Env.active) do
        packages.each do |package|
          puts "uninstalling #{package.name}"

          package.files.each do |file|
            FileUtils.rm_rf file
          end

          graph.remove_package(package)
        end
      end
    end

    def puts(msg)
      super "rip: #{msg}"
    end

    def abort(msg)
      super "rip: #{msg}"
    end
  end
end
