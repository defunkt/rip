module Rip
  module Commands
    o 'rip show PACKAGE'
    x 'Displays information about an installed package'
    def show(options = {}, name = nil, *args)
      if name.to_s.empty?
        ui.abort "Please give me the name of a package."
      end

      installed_package = manager.package(name)
      if installed_package.nil?
        ui.abort "The package '#{name}' doesn't seem to be installed"
      end

      ui.puts installed_package
      ui.puts "Depends on: #{display_package_list(manager.dependencies_for(name))}"
      ui.puts "Required by: #{display_package_list(manager.packages_that_depend_on(name))}"

      ui.puts "Files:\n\t#{manager.files(name).join("\n\t")}" if options[:f]
    end

  private
    def display_package_list(packages)
      return "Nothing" unless packages && packages.any?
      packages.join(", ")
    end
  end
end
