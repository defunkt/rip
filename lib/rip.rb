autoload :Pathname,   'pathname'
autoload :YAML,       'yaml'
autoload :OpenStruct, 'ostruct'
autoload :Escape,     'escape'

require 'rip/core_ext/string'

module Rip
  autoload :Parser,      'rip/parser'
  autoload :Package,     'rip/environment'
  autoload :Environment, 'rip/environment'
  autoload :Helpers,     'rip/helpers'
  autoload :Requirement, 'rip/requirement'

  extend self
  attr_accessor :dir, :env

  def dir
    @dir ||= realpath(ENV['RIPDIR'])
  end

  def env
    @env ||= ENV['RIPENV']
  end

  def packages
    @packages ||= "#{dir}/.packages"
  end

  def cache
    @cache ||= "#{dir}/.cache"
  end

  def active
    @active ||= "#{dir}/active"
  end

  def envdir
    @envdir ||= "#{dir}/#{env}"
  end

  def envs
    @envs ||= Dir["#{dir}/*"].map { |f| File.basename(f) }.reject do |ripenv|
      ripenv == 'active' || ripenv[0].chr == '.'
    end
  end

  def processes
    @processes ||= (ENV['RIPPROCESSES'] || 1).to_i
  end

  def ruby
    @ruby ||= ENV['RIPRUBY'] || `which ruby`.chomp
  end

  def md5(string)
    require 'digest'
    Digest::MD5.hexdigest(string.to_s)
  end

  def realpath(path)
    return unless path
    path = Pathname.new(path)
    path.exist? ? path.realpath.to_s : nil
  end
end
