#!/usr/bin/env ruby

autoload :Rip, 'rip'

##
# doctest: Simplest parsing of args.
#
# >> parse_args %w( install -f )
# => ["install", { :f => true }, []]
#
# >> parse_args %w( install -f=force )
# => ["install", { :f => "force" }, []]
#
# >> parse_args %w( install -f force name )
# => ["install", { :f => true }, [ "force", "name" ]]
#
# >> parse_args %w( install something )
# => ["install", {}, [ "something" ]]

def parse_args(args)
  command = args.shift
  options = args.select { |piece| piece =~ /^-/ }
  args   -= options
  options = options.inject({}) do |hash, flag|
    key, value = flag.split('=')
    hash[key.sub('-','')] = value.nil? ? true : value
    hash
  end

  [command, options, args]
end

if $0 == __FILE__
  command, options, args = parse_args(ARGV)

  if command.nil? || command == '' || !Rip::Commands.respond_to?(command)
    command = :help
  end

  Rip::Commands.send(command, options, *args)
end
