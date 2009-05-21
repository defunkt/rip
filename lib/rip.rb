require 'fileutils'

require "rip/memoize"
require "rip/commands"
require "rip/env"
require "rip/setup"
require "rip/package_api"
require "rip/package"
require "rip/git_package"
require "rip/file_package"
require "rip/gem_package"
require "rip/dependency_manager"

module Rip
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
