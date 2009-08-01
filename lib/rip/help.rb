module Rip
  # tasty dsl for adding help text
  module Help

    def show_help(command, commands = commands)
      subcommand = command.to_s.empty? ? nil : "#{command} "
      ui.puts "Usage: rip #{subcommand}COMMAND [options]", ""
      ui.puts "Commands available:"

      show_command_table begin
        commands.zip begin
          commands.map { |c| @help[c].first unless @help[c].nil? }
        end
      end
    end

  private
    def ui
      Rip.ui
    end

    def o(usage)
      @usage ||= {}
      @next_usage = usage
    end

    def x(help = '')
      @help ||= {}
      @next_help ||= []
      @next_help.push help
    end

    def method_added(method)
      @help[method.to_s] = @next_help if @next_help
      @usage[method.to_s] = @next_usage if @next_usage
      @next_help = nil
      @next_usage = nil
    end

    def show_command_table(table)
      offset = table.map {|a| a.first.size }.max + 2
      offset += 1 unless offset % 2 == 0

      table.each do |(command, help)|
        ui.puts "  #{command}" << ' ' * (offset - command.size) << help.to_s
      end
    end
  end
end