require 'rake/testtask'


#
# Helpers
#

def command?(command)
  !`type #{command} 2> /dev/null`.empty?
end

if ENV['RUBYLIB']
  ENV['RUBYLIB'] += ':lib/'
else
  ENV['RUBYLIB'] = 'lib/'
end


#
# Tests
#

task :default => :test

if command? :turn
  desc "Run tests"
  task :test do
    suffix = "-n #{ENV['TEST']}" if ENV['TEST']
    sh "turn test/*.rb #{suffix}"
  end
else
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
  end
end

if command? :kicker
  desc "Launch Kicker (like autotest)"
  task :kicker do
    puts "Kicking... (ctrl+c to cancel)"
    exec "kicker -e rake test lib"
  end
end

desc "Run a git-daemon for the tests."
task "daemon:git" do
  cmd = "git daemon --export-all --base-path=test/fixtures"
  puts "Running #{cmd}"
  sh cmd
end

desc "Run a gem server for the tests."
task "daemon:gem" do
  cmd = "gem server --dir test/fixtures/gems --no-daemon"
  puts "Running #{cmd}"
  sh cmd
end

desc "Run gem and git daemons for the tests."
multitask :daemons => %w( daemon:git daemon:gem )


#
# Ron
#

if command? :ronn
  desc "Show the manual"
  task :man => "man:build" do
    exec "man man/man1/rip.1"
  end

  desc "Build the manual"
  task "man:build" do
    sh "ronn -br5 --organization=DEFUNKT --manual='rip manual' man/**/*.ronn"
  end
end


#
# Installation
#

desc "Installs Rip"
task :install do
  prefix = ENV['PREFIX'] || ENV['prefix'] || '/usr/local'
  bindir = ENV['BINDIR'] || ENV['bindir'] || "#{prefix}/bin"
  libdir = ENV['LIBDIR'] || ENV['libdir'] || "#{prefix}/lib/rip"

  mkdir_p bindir
  Dir["bin/*"].each do |f|
    cp f, bindir, :preserve => true, :verbose => true
  end

  mkdir_p libdir
  Dir["lib/**/*.rb"].each do |f|
    cp f, libdir
  end
end
