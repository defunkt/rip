require 'fileutils'

module Rip
  def self.dir
    return @dir if @dir

    dir = ENV['RIPDIR'].to_s

    if dir.empty?
      ui.puts "rip: RIPDIR env variable not found. Did you run `rip setup` after installation?"
      ui.puts "rip: Continuing..."
    end

    dir = File.expand_path(dir)
    FileUtils.mkdir_p dir unless File.exists? dir
    @dir = dir
  end

  def self.dir=(dir)
    @dir = dir
  end

  def self.ui
    @ui ||= Rip::UI.new(STDOUT)
  end

  def self.ui=(io)
    @ui = Rip::UI.new(io)
  end
end

# load rip files

require 'rip/ui'
require 'rip/version'
require 'rip/env'
require 'rip/memoize'
require 'rip/installer'
require 'rip/package_api'
require 'rip/package'
require 'rip/package_manager'
require 'rip/setup'
require 'rip/sh/git'


# load rip packages - order is important

require 'rip/packages/ripfile_package'
require 'rip/packages/git_package'
require 'rip/packages/http_package'
require 'rip/packages/gem_package'
require 'rip/packages/dir_package'
require 'rip/packages/file_package'
require 'rip/packages/remote_gem_package'
