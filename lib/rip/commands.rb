module Rip
  module Commands
    extend self
    extend Help

    def invoke(args)
      command, options, args = parse_args(args)

      if command.nil? && (options[:v] || options[:version])
        command = :version
      end

      if command.nil? || command == '' || options[:h] || options[:help]
        command = :help
      end

      command = find_command(command)

      begin
        send(command, options, *args)
      rescue => e
        if options[:error]
          raise e
        else
          ui.puts "rip: #{command} failed"
          ui.puts "-> #{e.message}"
        end
      end
    end

    def load_plugin(file)
      begin
        require file
      rescue Exception => e
        ui.puts "rip: plugin not loaded (#{file})"
        ui.puts "-> #{e.message}", ''
      end
    end

    def public_instance_methods
      super - %w( invoke load_plugin public_instance_methods )
    end

  private
    def manager(env = nil)
      @manager ||= PackageManager.new(env)
    end

    def find_command(command)
      matches = public_instance_methods.select do |method|
        method =~ /^#{command}/
      end

      if matches.size == 0
        ui.puts "Could not find the command: #{command.inspect}"
        ui.puts
        :help
      elsif matches.size == 1
        matches.first
      else
        ui.abort "rip: which command did you mean? #{matches.join(' or ')}"
      end
    end

    def parse_args(args)
      options = args.select { |piece| piece =~ /^-/ }
      args   -= options
      command = args.shift
      options = options.inject({}) do |hash, flag|
        key, value = flag.split('=')
        hash[key.sub(/^--?/,'').intern] = value.nil? ? true : value
        hash
      end

      [ command, options, args ]
    end
  end
end


#
# rip plugin commands
#

# load lib/rip/commands/*.rb from rip itself
if File.exists? dir = File.join(File.dirname(__FILE__), 'commands')
  Dir[dir + '/*.rb'].each do |file|
    Rip::Commands.load_plugin(file)
  end
end

# load ~/.rip/rip-commands/*.rb
if File.exists? dir = File.join(Rip.dir, 'rip-commands')
  Dir[dir + '/*.rb'].each do |file|
    Rip::Commands.load_plugin(file)
  end
end

# load lib/rip/commands/*.rb from the active ripenv
if File.exists? dir = File.join(Rip::Env.active_dir, 'lib', 'rip', 'commands')
  Dir[dir + '/*.rb'].each do |file|
    Rip::Commands.load_plugin(file)
  end
end
