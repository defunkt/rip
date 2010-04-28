require 'rake/testtask'

if ENV['RUBYLIB']
  ENV['RUBYLIB'] += ':lib/'
else
  ENV['RUBYLIB'] = 'lib/'
end

task :default => :test

if system("which turn &> /dev/null")
  desc "Run the tests using `turn`."
  task :test do
    exec "turn test/*.rb"
  end
else
  task :test => "test:unit"
end

Rake::TestTask.new "test:unit" do |t|
  t.libs << 'lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = false
end

desc "Build rip manual"
task :build_man do
  sh "ron -br5 --organization=DEFUNKT --manual='Rip Manual' man/*.ron"
end

desc "Show rip manual"
task :man => :build_man do
  exec "man man/*.{1,5}"
end

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
