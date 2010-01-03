module Rip
  # Stores state for the current rip environment.
  # Keys can be added or removed by any sort of plugin or third party
  # code.
  # The following keys are reserved for rip's internal use:
  #
  #   packages: A hash keyed by package names.
  #             Each key is itself a hash consisting of the following
  #             keys:
  #     version:  The current version of this package.
  #     parents:  An array of packages which list this package as a
  #               dependency.
  #     children: An array of packages which this package lists as
  #               dependencies.
  module DB
    extend self

    def packages
      self['packages']
    end

    def package(name)
      self['packages'][name]
    end

    def [](key)
      data[key]
    end

    def []=(key, value)
      data[key] = value
    end

    def file
      "#{Rip.dir}/#{Rip.env}/#{Rip.env}.ripenv"
    end

    def save
      File.open(file, 'w') do |f|
        f.puts YAML.dump(data)
      end
      true
    end

    def data
      @data ||= data!
    end

    def data!
      require 'yaml'
      File.exists?(file) ? YAML.load_file(file) : {}
    end
  end
end
