module Rip
  class DependencyGraph
    attr_reader :packages, :files

    def initialize(env = nil)
      @env = env || Rip::Env.active
      load

      @packages ||= {}
      @heritage ||= {}
      @lineage ||= {}
      @files ||= {}
    end

    def add_dependency(parent, name, version = nil)
      @heritage[name] ||= []
      @heritage[name].push(parent)
      @lineage[parent] ||= []
      @lineage[parent].push(name)
    end

    def add_package(name, version = nil)
      version ||= 'master'

      if @packages.has_key?(name) && @packages[name] != version
        puts "#{name} requested at #{version} by SOMEONE"
        puts "#{name} already #{@packages[name]} by #{@graph[name]}"
        abort "sorry."
      end

      # already installed?
      if @packages.has_key? name
        false
      else
        @packages[name] = version
        true
      end
    end

    def installed?(name)
      @packages.has_key? name
    end

    def remove(name)
      Array(@heritage[name]).each do |dep|
        @lineage[dep].delete(name) if @lineage[dep].respond_to? :delete
      end

      @heritage.delete(name)
      @lineage.delete(name)
      @packages.delete(name)
      save
    end

    def packages_that_depend_on(name)
      @lineage[name] || []
    end

    def add_files(name, file_list = [])
      @files[name] ||= []
      @files[name].concat file_list
    end

    def files(name)
      @files[name]
    end

    def save
      File.open(path, 'w') do |f|
        f.puts marshal_payload
        f.flush
      end
    end

    def load
      marshal_read File.read(path) if File.exists? path
    end

    def path
      File.join(Rip.dir, @env, "#{@env}.ripenv")
    end

    def marshal_payload
      Marshal.dump [ @packages, @heritage, @lineage, @files ]
    end

    def marshal_read(data)
      @packages, @heritage, @lineage, @files = Marshal.load(data)
    end
  end
end
