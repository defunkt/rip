module Rip
  module Commands
    x 'Checks that your rip installation is valid.'
    def check(*args)
      Setup.check_installation
      ui.puts "All systems go."
    rescue Setup::StaleEnvironmentError, Setup::InstallationError => e
      ui.puts e.message
    rescue => e
      ui.puts "Installation failed: #{e.message}"
    end

    o 'rip install SOURCE [options]'
    x 'Installs a package from SOURCE.'
    x '-f forces installation (overwrites existing)'
    def install(options = {}, source = nil, version = nil, *args)
      if source.to_s.empty?
        ui.abort "Please tell me what to install."
      end

      package = Rip::Package.for(source, version)

      if !package
        ui.abort "I don't know how to install #{source}"
      end

      if options[:f]
        Installer.new.uninstall(package) if package.installed?
        Installer.new.install(package)
      elsif package.installed?
        ui.puts "#{package} already installed"
      else
        installer = Installer.new
        installer.install(package)
#         puts "#{installer.installed.size.to_i} packages installed"
      end
    end
  end
end
