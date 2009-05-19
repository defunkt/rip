module Rip
  class DependencyGraph
    def initialize(env = nil)
      @env = env
      load

      @packages ||= {}
      @heritage ||= {}
      @files ||= {}
    end

    def add_dependency(parent, name, version = nil)
      @heritage[name] ||= []
      @heritage[name].push(parent)
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
      Marshal.dump [ @packages, @heritage, @files ]
    end

    def marshal_read(data)
      @packages, @heritage, @files = Marshal.load(data)
    end
  end
end
