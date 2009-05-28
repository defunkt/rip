# file: lib/rip/commands/build.rb
#
# rip build
# Builds Ruby extensions for installed packages

module Rip
  module Commands
    def build(options={}, *packages)
      packages.each do |package_name|
        puts "building package: #{package_name}"
        package = manager.package(package_name)

        Dir["#{package.cache_path}/**/extconf.rb"].each do |build_file|
          build_dir = File.dirname(build_file)
          Dir.chdir(build_dir) {
            system "ruby extconf.rb"
            system "make install RUBYARCHDIR=#{manager.dir}/lib"
          }
        end
      end
    end
  end
end
