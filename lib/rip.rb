require 'yaml'

module Rip
  autoload :Parser, 'rip/parser'
  autoload :DB, 'rip/package'
  autoload :Dep, 'rip/deps'
  autoload :Deps, 'rip/deps'
  autoload :GitPackage, 'rip/packages/git_package'
  autoload :Helpers, 'rip/helpers'

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

  def md5(string)
    require 'digest'
    Digest::MD5.hexdigest(string.to_s)
  end
end
