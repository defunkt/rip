module Rip
  module FileUtils
    extend self

    def mkdir_p(path)
      FileSystem.add(path, MockDir.new)
    end

    def rm(path)
      if dir = FileSystem.find(path)
        dir.parent.delete(dir.name)
      end
    end
    alias_method :rm_rf, :rm

    def ln_s(target, path)
      FileSystem.add(path, MockSymlink.new(target))
    end
  end

  class File
    PATH_SEPARATOR = '/'

    def self.join(*parts)
      parts * PATH_SEPARATOR
    end

    def self.exists?(path)
      FileSystem.find(path)
    end

    def self.expand_path(path)
      ::File.expand_path(path)
    end

    def self.readlink(path)
      symlink = FileSystem.find(path)
      FileSystem.find(symlink.target).to_s
    end
  end

  class Dir
  end

  module FileSystem
    extend self

    def fs
      @fs ||= MockDir.new('.')
    end

    def clear
      @fs = nil
    end

    def find(path)
      parts = path_parts(path)

      target = parts[0...-1].inject(fs) do |dir, part|
        dir[part] || {}
      end

      target[parts.last]
    end

    def add(path, object)
      parts = path_parts(path)

      d = parts[0...-1].inject(fs) do |dir, part|
        dir[part] ||= MockDir.new(part, dir)
      end

      object.name = parts.last
      object.parent = d
      d[parts.last] = object
    end

    def path_parts(path)
      path.split(File::PATH_SEPARATOR)
    end
  end

  class MockDir < Hash
    attr_accessor :name, :parent
    def initialize(name = nil, parent = nil)
      @name = name
      @parent = parent
    end

    def to_s
      if parent && parent.to_s != '.'
        parent.to_s + '/' + name
      else
        name
      end
    end
  end

  class MockSymlink
    attr_accessor :name, :target
    def initialize(target)
      @target = target
    end

    def inspect
      "symlink(#{target.split('/').last})"
    end

    def method_missing(*args, &block)
      FileSystem.find(target).send(*args, &block)
    end
  end
end

Object.class_eval do
  remove_const(:Dir)
  remove_const(:File)
  remove_const(:FileUtils)
end

File = Rip::File
FileUtils = Rip::FileUtils
Dir = Rip::Dir
