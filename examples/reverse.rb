#
# This file would normally live in lib/rip/commands or ~/.rip/rip-commands
# 

module Rip
  module Commands
    def reverse(options = {}, package = nil, *args)
      puts "ripenv: #{Rip::Env.active}", ''
      if package
        puts package.reverse
      else
        manager.packages.each do |package|
          puts package.to_s.reverse
        end
      end
    end
  end
end
