module Rip
  module Sh
    module Gem
      extend self

      def check?
        !`which #{gembin}`.strip.empty?
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
      
      def fetch(name, version=nil)
        source_string = name
        source_string += " --version '#{version}'" if version
        rgem("fetch #{source_string}") =~ /Downloaded (.+)/
      end

      def dependencies(path_to_gem)
        require 'rubygems' # to get the specification class
        spec = YAML.load(rgem("specification #{path_to_gem}"))
        spec.dependencies.select { |d| d.type != :development }.map { |d| Package.for(d.name, d.version_requirements.to_s) }
      end

      def gembin
        ENV['GEMBIN'] || 'gem'
      end
    end
  end
end
