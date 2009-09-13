require 'fileutils'

module Rip
  # Returns the Rip data directory. That is, the directory which contains
  # all the Rip environment directories.
  def self.dir
    return @dir if @dir

    env = ENV['RIPDIR'].to_s
    if env.empty?
      dir = File.join(user_home, ".rip")
    else
      dir = File.expand_path(env)
    end

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

  def self.user_home
    @home ||= ENV['HOME']
  end
end

# load rip files

require 'rip/ui'
require 'rip/version'
require 'rip/help'
require 'rip/env'
require 'rip/memoize'
require 'rip/installer'
require 'rip/package_api'
require 'rip/package'
require 'rip/package_manager'
require 'rip/setup'
require 'rip/sh/git'
require 'rip/sh/gem'


# load rip packages - order is important

require 'rip/packages/ripfile_package'
require 'rip/packages/git_package'
require 'rip/packages/http_package'
require 'rip/packages/gem_package'
require 'rip/packages/gemfile_package'
require 'rip/packages/dir_package'
require 'rip/packages/file_package'
require 'rip/packages/remote_gem_package'
