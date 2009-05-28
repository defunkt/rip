module Rip
  module Commands
    extend self

    def invoke(command, options, *args)
      if command.nil? || command == ''
        command = :help
      end

      command = find_command(command)

      begin
        send(command, options, *args)
      rescue => e
        if options[:error]
          raise e
        else
          puts "rip: #{command} failed"
          puts "-> #{e.message}"
        end
      end
    end

    def public_instance_methods
      super - %w( invoke public_instance_methods )
    end

  private
    def manager
      @manager ||= PackageManager.new
    end

    def find_command(command)
      matches = public_instance_methods.select do |method|
        method =~ /^#{command}/
      end

      if matches.size == 0
        nil
      elsif matches.size == 1
        matches.first
      else
        abort "rip: which command did you mean? #{matches.join(' or ')}"
      end
    end
  end
end


#
# rip plugin commands
#

# load ~/.rip/rip-commands/*.rb
if File.exists? dir = File.join(Rip.dir, 'rip-commands')
  Dir[dir + '/*.rb'].each do |file|
    require file
  end
end

# load lib/rip/commands/*.rb from the active ripenv
if File.exists? dir = File.join(Rip::Env.active_dir, 'lib', 'rip', 'commands')
  Dir[dir + '/*.rb'].each do |file|
    require file
  end
end


# load lib/rip/commands/*.rb from rip itself
if File.exists? dir = File.join(File.dirname(__FILE__), 'commands')
  Dir[dir + '/*.rb'].each do |file|
    require file
  end
end
