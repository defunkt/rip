require 'rake/clean'
require 'rake/testtask'


#
# Helpers
#

def command?(command)
  !`type #{command} 2> /dev/null`.empty?
end


#
# Tests
#

task :default => :test

if command? :turn
  desc "Run tests"
  task :test do
    suffix = "-n #{ENV['TEST']}" if ENV['TEST']
    sh "turn -Ilib:test test/*.rb #{suffix}"
  end
else
  Rake::TestTask.new do |t|
    t.libs << 'test'
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
  CLOBBER.include('man/*.{1,5}')
  CLOBBER.include('man/*.{1,5}.html')

  desc "Show the manual"
  task :man => "man:build" do
    exec "man man/rip.1"
  end

  desc "Build the manual"
  task "man:build" do
    sh "ronn -br5 --organization=DEFUNKT --manual='rip manual' man/*.ronn"
  end
end

#
# Site
#

desc "Build the site. Requires ronn."
task :site do
  require 'lib/rip/version'
  manuals = []
  mkdir_p mandir = "docs/manual/#{Rip::Version}"

  Dir["man/*.ronn"].each do |file|
    out = `ronn -5 -b #{file} 2>&1`.chomp
    if out =~ /(?:.+?): (.+)/
      file = File.basename($1)
      manuals << file
      mv $1, "#{mandir}/#{file}"
    end
  end

  index = '<div style="clear:both;"></div>'
  index << '<ol>'
  manuals.sort.each do |manual|
    name, section, ext = manual.split('.')
    index << "<li><a href='#{manual}'>#{name}(#{section})</a></li>"
  end
  index << '</ol>'

  require 'ronn'
  require 'ronn/document'
  require 'ronn/template'

  klass = Class.new(Ronn::Template) do
    def initialize(manuals, html)
      @manuals = manuals
      @html = html
    end

    def html
      @html
    end

    def section_heads
      false
    end

    def any_section_heads
      !!section_heads
    end

    def page_name
      ""
    end

    def manual
      "rip manual"
    end
    alias_method :title, :manual

    def organization
      "rip"
    end

    def date
      Time.now.strftime('%B %Y')
    end
  end

  view = klass.new(manuals, index)

  File.open("#{mandir}/index.html", 'w+') do |f|
    f.puts view.render
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
  Dir["lib/*"].each do |f|
    cp_r f, libdir
  end
end
