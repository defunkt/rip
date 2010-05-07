require 'rip'

if Rip.dir.to_s.empty? || Rip.env.to_s.empty?
  check = `rip-check`

  if $?.success?
    check.split("\n").each do |line|
      const, value = line.split("=")

      if const == 'RIPDIR'
        Rip.dir = value
      elsif const == 'RIPENV'
        Rip.env = value
      end
    end
  else
    print check
    exit 1
  end
end

# Clear out GIT_DIR incase we are running from a git subprocess
ENV.delete('GIT_DIR')

# ARGV.args vs ARGV.flags
def ARGV.flags
  select { |arg| arg =~ /^-/ }
end

def ARGV.args
  self - flags
end


RIPDIR     = Rip.dir
RIPENV     = Rip.env
RIPENVS    = Rip.envs
CACHEDIR   = Rip.cache
PACKAGEDIR = Rip.packages
ACTIVEDIR  = Rip.active

require 'fileutils'
include FileUtils
include Rip::Helpers
include Rip
