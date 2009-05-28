module Rip
  module Commands
    def uninstall(options = {}, name = nil, *args)
      if name.to_s.empty?
        abort "rip: please tell me what to uninstall"
      end

      force = options[:y] || options[:d]
      package = manager.package(name)

      if !package
        abort "rip: #{name} isn't installed"
      end

      dependents = manager.packages_that_depend_on(name)

      if dependents.any? && !force
        puts "You have requested to uninstall the package:"
        puts "  #{name} (#{package.version})"
        puts
        puts "The following packages depend on #{name}:"

        dependents.each do |dependent|
          puts "  #{dependent} (#{dependent.version})"
        end

        puts
        puts "If you remove this package one or more dependencies will not be met."
        puts "Pass -y if you really want to remove #{name}"
        abort "Pass -d if you want to remove #{name} and its dependents."
      end

      if force || dependents.empty?
        Installer.new.uninstall(package, options[:d])
        puts "Successfully uninstalled #{package} (#{package.version})"
      end
    end
  end
end
