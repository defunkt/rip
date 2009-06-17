module Rip
  module Commands
    o 'rip uninstall PACKAGE [options]'
    x 'Uninstalls a single Rip package (or rip itself).'
    x '-y removes the package no matter what.'
    x '-d removes the package and its dependents.'
    def uninstall(options = {}, name = nil, *args)
      if name.to_s.empty?
        ui.abort "Please tell me what to uninstall."
      end

      if name == 'rip' && !options[:y]
        ui.abort "Are you sure you want to uninstall rip? Pass -y if so."
      elsif name == 'rip' && options[:y]
        require 'rip/setup'
        return Rip::Setup.uninstall(true)
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
