module Rip
  class DependencyManager
    attr_reader :packages, :files

    def initialize(env = nil)
      @env = env || Rip::Env.active
      load

      # key is the package name, value is the current
      # installed version
      @packages ||= {}

      # key is the package name, value is an array of
      # libraries it depend on
      @heritage ||= {}

      # key is the package name, value is an array of
      # libraries that depend on it
      @lineage ||= {}

      # key is the package name, value is the source
      @sources ||= {}
    end

    def package(name)
      Package.for(@sources[name], @versions[name])
    end

    def packages_that_depend_on(name)
      @lineage[name.respond_to?(:name) ? name.name : name] || []
    end

    def files(name)
      Array(@files[name])
    end

    def installed?(name)
      @packages.has_key? name
    end

    def package_version(name)
      @packages[name]
    end

    def add_package(package, parent = nil)
      name = package.name
      version = package.version

      if @packages.has_key?(name) && @packages[name] != version
        puts "#{name} requested at #{version} by #{parent}"
        puts "#{name} already #{@packages[name]} by #{@heritage[name][0]}"
        abort "sorry."
      end

      if parent
        @heritage[name] ||= []
        @heritage[name].push(parent)
        @lineage[parent] ||= []
        @lineage[parent].push(name)
      end

      # already installed?
      if @packages.has_key? name
        false
      else
        @packages[name] = version
        @sources[name] = package.source
        save
        true
      end
    end

    def add_files(name, file_list = [])
      @files[name] ||= []
      @files[name].concat file_list
      save
    end

    def remove_package(name)
      Array(@heritage[name]).each do |dep|
        @lineage[dep].delete(name) if @lineage[dep].respond_to? :delete
      end

      @heritage.delete(name)
      @lineage.delete(name)
      @packages.delete(name)
      save
    end

    def path
      File.join(Rip.dir, @env, "#{@env}.ripenv")
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

    def marshal_payload
      Marshal.dump [ @packages, @heritage, @lineage, @files, @sources ]
    end

    def marshal_read(data)
      @packages, @heritage, @lineage, @files, @sources = Marshal.load(data)
    end
  end
end
