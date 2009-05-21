require 'fileutils'

require "rip/memoize"
require "rip/commands"
require "rip/installer"
require "rip/env"
require "rip/setup"
require "rip/package_api"
require "rip/package_manager"
require "rip/package"

Dir['rip/packages/*'].each do |file|
  require file
end

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
