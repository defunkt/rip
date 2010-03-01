module Rip
  module Helpers
    def rip(command, *args)
      bindir = File.dirname(__FILE__) + "/../../bin/"
      `#{bindir}/rip-#{command} #{args.join(' ')}`
    end

    def gem(command, *args)
      args << "-s #{ENV["GEM_SERVER"]}" if ENV["GEM_SERVER"]
      `gem #{command} #{args.join(' ')}`
    end

    def sh(*cmd)
      result = `#{cmd}`.chomp
      exit 1 unless $?.success?
      result
    end
  end
end
