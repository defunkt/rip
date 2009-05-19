require 'fileutils'

module Rip
  class Env
    def self.commands
      commands  = public_instance_methods
      commands -= superclass.public_instance_methods
      commands -= %w( call )
      commands
    end

    def initialize(rip_dir = nil)
      @rip_dir = rip_dir
    end

    def create(env)
      dir = File.join(rip_dir, env)

      if File.exists? dir
        "#{env} exists"
      else
        FileUtils.mkdir_p File.join(dir, 'bin')
        FileUtils.mkdir_p File.join(dir, 'lib')

        use env
        "created #{env}"
      end
    end

    def use(env)
      if !File.exists?(target = File.join(rip_dir, env))
        return "#{env} doesn't exist"
      end

      FileUtils.rm active_dir rescue Errno::ENOENT
      FileUtils.ln_s(target, active_dir)

      "using #{env}"
    end

    def delete(env)
      if active_env == env
        return "can't remove active environment"
      end

      if File.exists?(target = File.join(rip_dir, env))
        FileUtils.rm_rf target
        "removing #{env}"
      end
    end

    def list(env = nil)
      envs = Dir.glob(File.join(rip_dir, '*')).map do |env|
        env.split('/').last
      end

      envs -= %w( active rip-packages )

      if envs.empty?
        "none. make one with `rip env create <env>`"
      else
        envs.join(' ')
      end
    end

    def active
      active_env
    end

    def copy(env, new)
      dest = File.join(rip_dir, new)
      src  = File.join(rip_dir, env)

      if File.exists?(dest)
        return "#{new} exists"
      end

      if !File.exists?(src)
        return "#{env} doesn't exist"
      end

      FileUtils.cp_r src, dest
      use new
      "cloned #{env} to #{new}"
    end

    # for being lazy about what we have vs what we want.
    # enables javascript-style method calling where
    # the number of arguments doesn't need to match
    # the arity
    def call(meth, *args)
      arity = method(meth).arity.abs

      if arity == args.size
        send(meth, *args)
      elsif arity == 0
        send(meth)
      else
        send(meth, args[0, arity])
      end
    end

  private
    def rip_dir
      @rip_dir ||= Rip.dir
    end

    def active_dir
      File.join(rip_dir, 'active')
    end

    def active_env
      active = File.join(rip_dir, 'active')
      active = File.readlink(active)
      active.split('/').last
    end
  end
end
