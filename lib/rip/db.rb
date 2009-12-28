module Rip
  module DB
    extend self

    def [](key)
      data[key]
    end

    def []=(key, value)
      data[key] = value
    end

    def file
      "#{RIPDIR}/#{RIPENV}/#{RIPENV}.ripenv"
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
