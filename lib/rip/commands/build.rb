# file: lib/rip/commands/build.rb
#
# rip build
# Builds Ruby extensions for installed packages

module Rip
  module Commands
    o 'rip build PACKAGE'
    x "Attempts to build a package using extconf.rb"
    def build(options={}, *packages)
      packages.each do |package_name|
        package = manager.package(package_name)
        alerted = false

        Dir["#{package.cache_path}/**/extconf.rb"].each do |build_file|
          if !alerted
            ui.puts "rip: building #{package_name}"
            alerted = true
          end

          build_dir = File.dirname(build_file)
          Dir.chdir(build_dir) do
            system "ruby extconf.rb"
            system "make clean"
            system "make install sitearchdir=#{manager.dir}/lib"
          end
        end

        if !alerted && !options[:quiet]
          ui.puts "rip: don't know how to build #{package_name}"
        end
      end
    end
  end
end
