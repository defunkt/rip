module Rip
  class DependencyGraph
    def initialize(env = nil)
      @env = env
      @packages = {}
      @heritage = {}
    end

    attr_reader :packages, :heritage

    def add_dependency(parent, name, version = nil)
      version ||= 'master'

      added = add_package(name, version, parent)

      @heritage[name] ||= []
      @heritage[name].push(parent)

      added
    end

    def add_package(name, version = nil, parent = nil)
      version ||= 'master'

      if @packages.has_key?(name) && @packages[name] != version
        puts "#{name} requested at #{version} by #{parent}"
        puts "#{name} already #{@packages[name]} by #{@graph[name]}"
        abort "sorry."
      end

      ret = @packages.has_key?(name)
      @packages[name] = version
      return !ret
    end
  end
end
