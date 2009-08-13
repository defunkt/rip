module Rip
  module Gems
    extend self

    def check?
      `which #{gembin}`.strip.any?
    end

    def rgem(command)
      Timeout.timeout(30) do
        `#{gembin} #{command}`
      end
    rescue Timeout::Error
      ''
    end

    def dependencies(name)
      if rgem("dependency #{name} --remote") =~ /(Gem #{name}-.*?)(Gem|\z)/m
        $1.split("\n").grep(/runtime\s*\)/).map do |line|
          line =~ /([\w-]+)\s*\([~><=]+\s*((?:\d+\.?)+\d+|\d)/
          source, version = $1, $2
          if source
            Package.for(source, version)
          else
            nil
          end
        end.compact
      else
        []
      end
    end

    def gembin
      ENV['GEMBIN'] || 'gem'
    end
  end
end
