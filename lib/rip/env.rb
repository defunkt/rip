module Rip
  module Env
    extend self
    extend Help
    PRIVATE_ENV =  /^(rip-|active)/i

    def commands
      instance_methods - %w( call active_dir commands ui validate_ripenv )
    end

    x 'Create the SOURCE environment.'
    def create(env)
      dir = File.join(Rip.dir, env)

      if env.strip.empty?
        return "must give a ripenv to create"
      end

      if env.strip =~ PRIVATE_ENV
        return "invalid environment name"
      end

      if File.exists? dir
        "#{env} exists"
      else
        FileUtils.mkdir_p File.join(dir, 'bin')
        FileUtils.mkdir_p File.join(dir, 'lib')

        use env
        "created #{env}"
      end
    end

    x 'Activate the SOURCE environment.'
    def use(env)
      if env.strip.empty?
        return "must give a ripenv to use"
      end

      if error = validate_ripenv(env)
        return error
      end

      begin
        FileUtils.rm active_dir
      rescue Errno::ENOENT
      end
      FileUtils.ln_s(File.join(Rip.dir, env), active_dir)

      "using #{env}"
    end

    x 'Remove the SOURCE environment.'
    def delete(env)
      if active == env
        return "can't delete active environment"
      end

      if env.strip.empty?
        return "must give a ripenv to delete"
      end

      if env.strip =~ PRIVATE_ENV
        return "invalid environment name"
      end

      if File.exists?(target = File.join(Rip.dir, env))
        FileUtils.rm_rf target
        "deleted #{env}"
      else
        "can't find #{env}"
      end
    end

    x 'Display all rip environments.'
    def list(options = {})
      # check if we got passed an env. kinda ghetto.
      if options.is_a? String
        target_env = options
        options = {}
      end

      envs = Dir.glob(File.join(Rip.dir, '*')).map do |env|
        env.split('/').last
      end

      envs.reject! { |env| env =~ PRIVATE_ENV }

      if envs.empty?
        "none. make one with `rip env create <env>`"
      elsif target_env
        if error = validate_ripenv(target_env)
          return error
        end

        manager = PackageManager.new(target_env)
        output  = [ target_env, "" ]
        output += manager.packages
        output.join("\n")
      else
        output  = [ "all installed ripenvs", "" ]
        output += envs.map do |env|
          prefix = Rip::Env.active == env ? "* " : "  "
          if options[:p]
            packages = PackageManager.new(env).packages
            packages = packages.size > 3 ? packages[0, 3] + ['...'] : packages
            "#{prefix}#{env} - #{packages.join(', ')}"
          else
            "#{prefix}#{env}"
          end
        end
        output.join("\n")
      end
    end

    x 'Display the name of the active environment.'
    def active
      active = File.readlink(active_dir)
      active.split('/').last
    end

    x 'Clone the active environment.'
    def copy(new)
      if new.strip.empty?
        return "must give a ripenv to copy to"
      end

      dest = File.join(Rip.dir, new)
      src  = Rip::Env.active_dir
      env  = Rip::Env.active

      if File.exists?(dest)
        return "#{new} exists"
      end

      FileUtils.cp_r src, dest

      if File.exists? ripfile = File.join(dest, "#{env}.ripenv")
        FileUtils.cp ripfile, File.join(dest, "#{new}.ripenv")
        FileUtils.rm ripfile
      end

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
      elsif args.empty?
        send(meth, '')
      else
        send(meth, *args[0, arity])
      end
    end

    def active_dir
      File.join(Rip.dir, 'active')
    end

    def ui
      Rip.ui
    end

    def validate_ripenv(env)
      if env.strip =~ PRIVATE_ENV
        return "invalid environment name"
      end

      if !File.exists?(File.join(Rip.dir, env))
        return "#{env} doesn't exist"
      end
    end
  end
end
