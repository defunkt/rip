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
        puts "rip: the following packages depend on #{name}:"

        dependents.each do |dependent|
          puts "#{dependent} (#{dependent.version})"
        end

        puts "rip: pass -y if you really want to remove #{name}"
        abort "rip: pass -d if you want to remove #{name} and these dependents"
      end

      if force || dependents.empty?
        puts "rip: uninstalling #{package}"
        Installer.new.uninstall(package, options[:d])
      end
    end
  end
end
