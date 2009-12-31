check = `rip-check`

if $?.success?
  check.split("\n").each do |line|
    const, value = line.split("=")
    Object.const_set(const, value)
  end
else
  print check
  exit 1
end

RIPENVS = Dir["#{RIPDIR}/*"].map { |f| File.basename(f) }.reject do |ripenv|
  ripenv == 'active' || ripenv[0].chr == '.'
end

CACHEDIR  = "#{RIPDIR}/.cache"
ACTIVEDIR = "#{RIPDIR}/active"

require 'fileutils'
include FileUtils

require 'digest'

def md5(string)
  Digest::MD5.hexdigest(string.to_s)
end

require 'rip'
include Rip

def rip(command, *args)
  bindir = File.dirname(__FILE__) + "/../../bin/"
  `#{bindir}/rip-#{command} #{args.join(' ')}`
end
