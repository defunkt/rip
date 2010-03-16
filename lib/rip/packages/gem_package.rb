module Rip
  class GemPackage < Package
    def self.handle?(source)
      source =~ /^\w+$/
    end

    def name
      source
    end


    def cache_name
      "#{name}-#{version}-#{Rip.md5(source)}"
    end

    # TODO: better name
    def ref
      gems = gem("list #{source} --remote").split("\n")
      if gems.detect { |f| f =~ /^#{source} \((.+)\)/ }
        $1
      end
    end
  end
end
