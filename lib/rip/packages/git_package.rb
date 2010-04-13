module Rip
  class GitPackage < Package
    def self.handle?(source)
      source =~ /file:\/\// ||
        source =~ /git:\/\// ||
        source =~ /\.git/ ||
        File.directory?(source) && File.exists?("#{source}/HEAD")
    end

    attr_accessor :ref

    def initialize(source, path = nil, version = nil, ref = nil)
      super(source, path, version)
      @version ||= "master"
      @ref = ref
    end

    def package_name
      "#{name}-#{Rip.md5("#{source}#{path}#{ref}")}"
    end

    def name
      if source =~ /([^\/]+?)-.{32}/
        $1
      else
        super || source.split(%r{:|/}).last.chomp('.git')
      end
    end
  end
end
