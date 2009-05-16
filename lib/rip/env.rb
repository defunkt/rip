require 'fileutils'

module Rip
  class Env
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
        puts "#{env} exists"
      else
        FileUtils.mkdir_p File.join(dir, 'bin')
        FileUtils.mkdir_p File.join(dir, 'lib')

        puts "created #{env}"
        use env
      end
    end

    def use(env)
      if !File.exists?(target = File.join(rip_dir, env))
        abort "#{env} doesn't exist"
      end

      FileUtils.rm active_dir
      FileUtils.ln_s(target, active_dir)

      puts "using #{env}"
    end

    def delete(env)
      if active_env == env
        puts "can't remove active environment"
      end

      if File.exists?(target = File.join(rip_dir, env))
        FileUtils.rm_rf target
        puts "removing #{env}"
      end
    end

    def list(env = nil)
      envs = Dir.glob(File.join(rip_dir, '*')).map do |env|
        env.split('/').last
      end
      envs -= %w( active rip-packages )
      puts "#{envs.join(' ')}"
    end

    def active
      puts "#{active_env}"
    end

    def copy(env, new)
      dest = File.join(rip_dir, new)
      src  = File.join(rip_dir, env)

      if File.exists?(dest)
        abort "#{new} exists"
      end

      if !File.exists?(src)
        abort "#{env} doesn't exist"
      end

      FileUtils.cp_r src, dest
      puts "cloned #{env} to #{new}"
      use name
    end

  private
    def rip_dir
      if dir = ENV['RIPDIR']
        File.expand_path(dir)
      else
        abort "RIPDIR env variable not found. did you run setup.rb?"
      end
    end

    def active_dir
      File.join(rip_dir, 'active')
    end

    def active_env
      active = File.join(rip_dir, 'active')
      active = File.readlink(active)
      active.split('/').last
    end

    def abort(message)
      super "ripenv: #{message}"
    end

    def puts(message)
      super "ripenv: #{message}"
    end
  end
end
