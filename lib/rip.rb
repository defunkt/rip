require 'yaml'
require 'ostruct'

module Rip
  autoload :Parser,      'rip/parser'
  autoload :Environment, 'rip/environment'
  autoload :Package,     'rip/environment'
  autoload :Helpers,     'rip/helpers'

  extend self
  attr_accessor :dir, :env

  def packages
    "#{dir}/.packages"
  end

  def cache
    "#{dir}/.cache"
  end

  def active
    "#{dir}/active"
  end

  def envdir
    "#{dir}/#{env}"
  end

  def envs
    Dir["#{dir}/*"].map { |f| File.basename(f) }.reject do |ripenv|
      ripenv == 'active' || ripenv[0].chr == '.'
    end
  end

  def platform_hash
    ENV['RIPPLATFORM'] || md5(shell_ruby_platform)
  end

  # Shell out to ruby so we always get the shells activate ruby,
  # not whatever ruby version is running rip.
  def shell_ruby_platform
    `ruby -rrbconfig -e "puts RbConfig::CONFIG['sitearchdir']"`
  end

  def md5(string)
    require 'digest'
    Digest::MD5.hexdigest(string.to_s)
  end
end
