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

    def install
      Dir.chdir File.join(Rip.dir, 'rip-packages') do
        puts "cloning..."

        if File.exists? package
          Dir.chdir File.join(Dir.pwd, package) do
            `git pull origin master`
          end
        else
          `git clone #{@target} #{package}`
        end

        package_rb = File.join(path, 'lib', "#{name}.rb")
        package_lib = File.join(path, 'lib', name)
        package_bin = File.join(path, 'bin', name)


        dest = File.join(Rip.dir, Rip::Env.active)
        dest_lib = File.join(Rip.dir, Rip::Env.active, 'lib')
        dest_bin = File.join(Rip.dir, Rip::Env.active, 'bin')

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
end
