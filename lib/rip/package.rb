require 'fileutils'

module Rip
  class Package
    def initialize(target)
      @target = target
    end

    def install
      Dir.chdir Rip.dir do
        puts Dir.pwd
        puts "git clone #{@target}"
        puts "cp lib/package.rb ~/.rip/base/lib/package.rb"
        puts "cp lib/package ~/.rip/base/lib/package"
        puts "cp bin/* ~/.rip/base/bin"
        puts "installed!"
      end
    end
  end
end
