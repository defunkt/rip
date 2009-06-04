module Rip
  module Commands
    def uninstall(options = {}, name = nil, *args)
      if name.to_s.empty?
        ui.abort "Please tell me what to uninstall."
      end

      force = options[:y] || options[:d]
      package = manager.package(name)

      if !package
        ui.abort "#{name} isn't installed."
      end

      dependents = manager.packages_that_depend_on(name)

      if dependents.any? && !force
        ui.puts "You have requested to uninstall the package:"
        ui.puts "  #{package}"
        ui.puts
        ui.puts "The following packages depend on #{name}:"

        dependents.each do |dependent|
          ui.puts "  #{dependent}"
        end

        ui.puts
        ui.puts "If you remove this package one or more dependencies will not be met."
        ui.puts "Pass -y if you really want to remove #{name}"
        ui.abort "Pass -d if you want to remove #{name} and its dependents."
      end

      if force || dependents.empty?
        Installer.new.uninstall(package, options[:d])
        ui.puts "Successfully uninstalled #{package}"
      end
    end
  end
end
