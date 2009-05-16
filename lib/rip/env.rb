require 'fileutils'

module Rip
  class Env
    BaseDir = "~/.rip"

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

    def create(env)
      dir = File.join(rip_dir, env)

      if File.exists? dir
        puts "ripenv: #{env} exists"
      else
        FileUtils.mkdir_p File.join(dir, 'bin')
        FileUtils.mkdir_p File.join(dir, 'lib')

        puts "ripenv: created #{env}"
        use env
      end
    end

    def use(env)
      if !File.exists?(target = File.join(rip_dir, env))
        puts "ripenv: #{env} doesn't exist"
        return
      end

      FileUtils.rm active_dir
      FileUtils.ln_s(target, active_dir)

      puts "ripenv: using #{env}"
    end

    def delete(env)
      if active_env == env
        puts "ripenv: can't remove active environment"
      end

      if File.exists?(target = File.join(rip_dir, env))
        FileUtils.rm_rf target
        puts "ripenv: removing #{env}"
      end
    end

    def list(env = nil)
      envs = Dir.glob(File.join(rip_dir, '*')).map do |env|
        env.split('/').last
      end
      envs -= %w( active rip-packages )
      puts "ripenv: #{envs.join(' ')}"
    end

    def active
      puts "ripenv: #{active_env}"
    end

    def copy(env, new)
      dest = File.join(rip_dir, new)
      src  = File.join(rip_dir, env)

      if File.exists?(dest)
        puts "ripenv: #{new} exists"
        return
      end

      if !File.exists?(src)
        puts "ripenv: #{env} doesn't exist"
        return
      end

      FileUtils.cp_r src, dest
      puts "ripenv: cloned #{env} to #{new}"
      use name
    end

  private
    def rip_dir
      File.expand_path(BaseDir)
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
