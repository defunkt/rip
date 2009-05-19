require 'fileutils'

module Rip
  autoload :Commands,        "rip/commands"
  autoload :Env,             "rip/env"
  autoload :Setup,           "rip/setup"
  autoload :Package,         "rip/package"
  autoload :DependencyGraph, "rip/dependency_graph"

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
