require 'fileutils'

module Rip
  autoload :Commands,       'rip/commands'
  autoload :Env,            'rip/env'
  autoload :Installer,      'rip/installer'
  autoload :Memoize,        'rip/memoize'
  autoload :Package,        'rip/package'
  autoload :PackageAPI,     'rip/package_api'
  autoload :PackageManager, 'rip/package_manager'
  autoload :Setup,          'rip/setup'

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
