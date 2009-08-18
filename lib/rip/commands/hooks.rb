module Rip
  module Commands
    # Runs ~/.rip/active/hooks/before-leave after `rip use`
    # and ~/.rip/active/hooks/after-use when moving to another env.
    #
    # Each hook is passed the name of the active ripenv.
    alias_method :rip_hook_use, :use
    def use(*args)
      run_hook_if_exists('before-leave', Rip::Env.active)
      rip_hook_use(*args)
      run_hook_if_exists('after-use', Rip::Env.active)
    end
    private :rip_hook_use

    o 'rip hooks [edit|show] NAME'
    x 'Show or display hooks from the current environment'
    def hooks(options = {}, command = 'show', name = nil)
      if command == 'show'
        if name
          ui.puts File.read(path_to_hook(name))
        else
          known_hooks = Dir[hook_dir + "/*"].map { |f| File.basename(f) } * ', '
          ui.abort "Which hook do you want to show? (known hooks: #{known_hooks})"
        end
      elsif command == 'edit'
        ui.abort "Please provide a hook to edit (e.g. after-use)" unless name
        exec "$EDITOR #{path_to_hook(name)}"
      end
    end

  private
    def run_hook_if_exists(name, stdin = nil)
      hook = path_to_hook(name)
      if File.exists?(hook) && File.executable?(hook)
        system("echo #{stdin} | #{hook}")
      end
    end

    def path_to_hook(name)
      File.join(hook_dir, name)
    end

    def hook_dir
      File.join(Rip::Env.active_dir, 'rip-hooks')
    end
  end
end
