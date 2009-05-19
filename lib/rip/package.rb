require 'digest/md5'

module Rip
  class Package
    def initialize(target)
      @target = target
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

    def install(version = nil)
      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        fetch_package
        unpack_package(version)
        copy_files
      end
    end

    def uninstall
      puts "uninstalling..."

      dest = File.join(Rip.dir, Rip::Env.active)
      dest_lib = File.join(dest, 'lib')
      dest_bin = File.join(dest, 'bin', name)

      FileUtils.rm_rf File.join(dest_lib, "#{name}.rb") rescue nil
      FileUtils.rm_rf File.join(dest_lib, name) rescue nil
      FileUtils.rm_rf dest_bin rescue nil

      puts "uninstalled #{name}"
    end

    def fetch_package
      puts "fetching..."
      if File.exists? package
        Dir.chdir File.join(Dir.pwd, package) do
          `git fetch origin`
        end
      else
        `git clone #{@target} #{package}`
      end
    end

    def unpack_package(version = nil)
      puts "unpacking..."
      Dir.chdir File.join(Dir.pwd, package) do
        `git reset --hard #{version || 'origin/master'}`
      end
    end

    def copy_files
      puts "installing..."
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
  end
end
