module Rip
  module Commands

    # Generate necessary envs etc. in ~/.{bash,zsh,...}rc.
    #
    o "rip setup [script to modify]"
    x "Inserts required environment variables into your startup script."
    x
    x "Pass it the startup script you want to modify, otherwise it will"
    x "guess one."
    def setup(options = {}, script = nil)
      require "rip/setup"

      if Setup.setup_startup_script(script)
        ui.puts "rip: Your #{Setup.startup_script} script has been modified."
        ui.puts "rip: Please restart your shell or type `source #{Rip::Setup.startup_script}` for the changes to become effective."
      end
    end

  end
end
