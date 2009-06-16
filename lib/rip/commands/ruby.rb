module Rip
  module Commands
    o 'ruby ENV ARGS'
    x 'Runs a Ruby instance in a particular environment.'
    def ruby(options={}, *args)
      selected_env = File.join(Rip.dir, ARGV.shift, "lib")
      path = (ENV["RUBYLIB"] || "").split(":")
      active_env = File.join(Rip.dir, "active", "lib")
      path -= [active_env]
      path += [selected_env]
      ENV["RUBYLIB"] = path.join(":")
      exec(ENV['RUBYBIN'] || "ruby", *ARGV)
    end
  end
end
