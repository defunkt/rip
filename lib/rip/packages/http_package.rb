require 'net/http'
require 'date'

module Rip
  class HTTPPackage < Package
    handles 'http://'

    def exists?
      code = Net::HTTP.get_response(URI.parse(source)).code
      code.to_i == 200
    end

    memoize :name
    def name
      source.split('/').last
    end

    def meta_package?
      true
    end

    def fetch!
      FileUtils.rm_rf cache_path
      FileUtils.mkdir_p cache_path
      File.open(File.join(cache_path, name), 'w') do |f|
        f.puts Net::HTTP.get(URI.parse(source))
      end
    end

    def unpack!
      installer = Installer.new
      installer.install actual_package
      installer.manager.sources[actual_package.name] = source
      installer.manager.save
    end

    def version
      actual_package ? actual_package.version : super
    end

    def actual_package
      Package.for(File.join(cache_path, name))
    end
  end
end
