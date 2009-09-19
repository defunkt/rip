module Rip
  class Installer
    include Memoize

    attr_reader :installed
    def initialize
      @installed = {}
      @uninstalled = {}
    end

    memoize :manager
    def manager
      PackageManager.new
    end

    def install(package, parent = nil)
      if !package.exists?
        error = package.to_s
        error += " requested by #{parent} but" if parent
        error += " not found at #{package.source}"
        ui.abort error
      end

      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        begin
          installed = @installed[package.name] || package.installed?

          return if installed
          @installed[package.name] = package

          if !package.meta_package? && !package.version
            ui.abort "can't install #{package} - it has no version"
          end

          package.fetch
          package.unpack

          parent_package = (parent && parent.meta_package?) ? parent.actual_package : parent
          manager.add_package(package, parent) unless package.meta_package?

          install_dependencies(package)
          build_extensions(package)
          copy_files(package)
          cleanup(package)
          ui.puts "Successfully installed #{package}" unless package.meta_package?
          true

        rescue FileConflict, VersionConflict => e
          ui.puts e.message
          rollback
          ui.abort "installation failed"

        rescue => e
          rollback
          raise e
        end
      end
    end

    def install_dependencies(package)
      package.dependencies.each do |dependency|
        success = install(dependency, package)
        package.run_hook(:dependency_installed, dependency, success)
      end
    end

    def build_extensions(package)
      Rip::Commands.build({:quiet => true}, package)
    end

    def copy_files(package)
      package_lib = File.join(package.cache_path, 'lib')
      package_bin = File.join(package.cache_path, 'bin')

      dest = Rip::Env.active_dir
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin')

      if File.exists? package_lib
        FileUtils.cp_r package_lib + '/.', dest_lib
      end

      if File.exists? package_bin
        FileUtils.cp_r package_bin + '/.', dest_bin, :preserve => true
      end
    end

    def cleanup(package)
      FileUtils.rm_rf package.cache_path unless package.cached?
    end

    def rollback
      @installed.values.each do |package|
        uninstall(package)
        cleanup(package)
      end
    end

    def uninstall(package, remove_dependencies = false)
      packages = [package]

      if remove_dependencies
        packages.concat manager.packages_that_depend_on(package.name)
      end

      Dir.chdir Rip::Env.active_dir do
        packages.each do |package|
          begin
            next if @uninstalled[package.name]
            @uninstalled[package.name] = true

            dirs = []

            package.files.each do |file|
              if File.directory?(file)
                dirs << file
                next
              end
              FileUtils.rm file if File.exist?(file)
            end

            dirs.sort.reverse.each do |dir|
              if File.exist?(dir) and Dir["#{dir}/*"].empty?
                FileUtils.rmdir dir
              end
            end

            manager.remove_package(package)
          rescue => e
            ui.puts e.message
            next
          end
        end
      end
    end

    def rakebin
      ENV['RAKEBIN'] || 'rake'
    end

    def ui
      Rip.ui
    end
  end
end
