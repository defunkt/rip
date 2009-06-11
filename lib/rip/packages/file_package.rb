require 'date'

module Rip
  class FilePackage < Package
    handles do |source|
      File.file?(source)
    end

    def initialize(source, *args)
      super
      @source = File.expand_path(source)
    end

    def exists?
      File.file? source
    end

    memoize :name
    def name
      source.split('/').last
    end

    def version
      if name.match(/-((?:\d+\.?)+\d+)\.rb$/)
        $1
      else
        Date.today.to_s
      end
    end

    def fetch!
      FileUtils.rm_rf cache_path
      FileUtils.mkdir_p cache_path
      FileUtils.cp_r source, cache_path
    end

    def files!
      fetch

      Dir.chdir cache_path do
        file = File.readlines(source)[0...5].detect do |line|
          line =~ /^# ?file:(.+)/
        end

        if file
          dir = File.dirname($1)
          file = File.basename($1)
          [ File.join(Rip::Env.active_dir, dir, file) ]
        else
          [ File.join(Rip::Env.active_dir, 'lib', name) ]
        end
      end
    end

    def unpack!
      Dir.chdir cache_path do
        files.each do |file|
          FileUtils.mkdir_p File.dirname(file)
          FileUtils.cp File.join(cache_path, name), file
        end
      end
    end
  end
end
