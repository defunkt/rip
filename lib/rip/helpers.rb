module Rip
  module Helpers
    def rip(command, *args)
      bindir = File.dirname(__FILE__) + "/../../bin/"
      sh "#{bindir}/rip-#{command}", *args
    end

    def gem(command, *args)
      args << "-s #{ENV["GEM_SERVER"]}" if ENV["GEM_SERVER"]
      sh "gem", command, *args
    end

    def sh(*cmd)
      result = `#{cmd}`.chomp

      if $?.success?
        result
      else
        exit 1
      end
    end
  end
end
