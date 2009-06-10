# file:lib/rip/commands/debug.rb
#
# This file would normally live in lib/rip/commands or ~/.rip/rip-commands
#
# See the `Plugins` section of the README for more information.
#

module Rip::Commands
  def debug(options, *args)
    puts "options: #{options.inspect}"
    puts "args: #{args.inspect}"
  end
end
