#
# This file would normally live in lib/rip/commands or ~/.rip/rip-commands
# 

module Rip::Commands
  def debug(options, *args)
    puts "options: #{options.inspect}"
    puts "args: #{args.inspect}"
  end
end
