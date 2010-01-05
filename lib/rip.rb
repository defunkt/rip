module Rip
  extend self
  attr_accessor :dir, :env

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

require 'rip/package'
require 'rip/db'
require 'rip/deps'
