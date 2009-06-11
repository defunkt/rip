module Rip
  module Commands
    o 'cmd ENV COMMAND'
    x 'Runs a Ruby command in a particular environment.'
    def cmd(options={}, *args)
      selected_env = File.join(Rip.dir, ARGV.shift, "lib")
      path = (ENV["RUBYLIB"] || "").split(":")
      active_env = File.join(Rip.dir, "active", "lib")
      path -= [active_env]
      path += [selected_env]      
      ENV["RUBYLIB"] = path.join(":")
      exec("ruby", *ARGV)
    end
  end
end