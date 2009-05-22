module Rip
  module Env
    extend self

    def commands
      instance_methods - %w( call active_dir commands )
    end

    def create(env)
      dir = File.join(Rip.dir, env)

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
      if !File.exists?(target = File.join(Rip.dir, env))
        return "#{env} doesn't exist"
      end

      FileUtils.rm active_dir rescue Errno::ENOENT
      FileUtils.ln_s(target, active_dir)

      "using #{env}"
    end

    def delete(env)
      if active == env
        return "can't remove active environment"
      end

      if File.exists?(target = File.join(Rip.dir, env))
        FileUtils.rm_rf target
        "removing #{env}"
      else
        "can't find #{env}"
      end
    end

    def list(env = nil)
      envs = Dir.glob(File.join(Rip.dir, '*')).map do |env|
        env.split('/').last
      end

      envs.reject! { |env| env =~ /^(rip-|active)/ }

      if envs.empty?
        "none. make one with `rip env create <env>`"
      else
        envs.join(' ')
      end
    end

    def active
      active = File.join(Rip.dir, 'active')
      active = File.readlink(active)
      active.split('/').last
    end

    def copy(env, new)
      dest = File.join(Rip.dir, new)
      src  = File.join(Rip.dir, env)

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

    def active_dir
      File.join(Rip.dir, 'active')
    end
  end
end
