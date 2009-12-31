# Start this up to run the fetch tests.

require 'fileutils'
include FileUtils

def write(file, content = nil)
  File.open(file, 'w') { |f| f.puts(content.to_s) }
end

def git(command)
  `git #{command}`
end


mkdir_p "repo"
cd "repo"

git "init"
mkdir_p "bin"
mkdir_p "lib"
mkdir_p "lib/repo"
mkdir_p "man"

write "bin/repo", "#!/bin/sh\necho yay"
write "lib/repo.rb"
write "lib/repo/stuff.rb"
write "man/repo.1"
write "man/repo.7"
write "README.md"

git "add *"
git "commit -m 'yay'"
cd ".."

at_exit do
  rm_rf "repo"
end

puts "Running git-daemon"
system "git daemon --export-all --base-path=."
