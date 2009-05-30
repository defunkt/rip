require 'fileutils'

module Rip
  def self.rip_autoload(class_symbol, path)
    autoload class_symbol, File.dirname(__FILE__) + '/rip/' + path
  end
  rip_autoload :Commands,       'commands'
  rip_autoload :Env,            'env'
  rip_autoload :Installer,      'installer'
  rip_autoload :Memoize,        'memoize'
  rip_autoload :Package,        'package'
  rip_autoload :PackageAPI,     'package_api'
  rip_autoload :PackageManager, 'package_manager'
  rip_autoload :Setup,          'setup'

  def self.dir
    return @dir if @dir

    dir = ENV['RIPDIR'].to_s

    if dir.empty?
      abort "RIPDIR env variable not found. did you run setup.rb?"
    end

    dir = File.expand_path(dir)
    FileUtils.mkdir_p dir unless File.exists? dir
    @dir = dir
  end

  def self.dir=(dir)
    @dir = dir
  end
end

# load package types, (git, gem, etc)

Dir[File.dirname(__FILE__) + '/rip/packages/*_package.rb'].each do |file|
  require file
end
