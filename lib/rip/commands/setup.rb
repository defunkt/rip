module Rip
  module Commands

    # Generate necessary envs etc. in ~/.{bash,zsh,...}rc.
    #
    o "rip setup"
    x "Inserts required environment variables into your startup script."
    def setup(options = {})
      require "rip/setup"

      if Setup.setup_startup_script
        ui.puts "rip: Your #{Setup.startup_script} script has been modified."
        ui.puts "rip: You may need to source it or start a new shell session."
      else
        ui.puts "rip: Setup not completed, see above."
      end
    end

  end
end
