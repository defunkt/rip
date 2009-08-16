module Rip
  module Sh
    module Gem
      extend self

      def check?
        `which #{gembin}`.strip.any?
      end

      def rgem(command)
        Timeout.timeout(30) do
          `#{gembin} #{command} 2> /dev/null`
        end
      rescue Timeout::Error
        ''
      end

      @@exists_cache = {}

      def exists?(name)
        return false unless name =~ /^[\w-]+$/
        @@exists_cache[name] ||= rgem("search #{name} --remote").split("\n").select { |f| f =~ /^#{name} / }.any?
      end
      
      def fetch(name)
        rgem("fetch #{name}") =~ /Downloaded (.+)/
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
end
