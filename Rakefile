require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs      << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose    = true
end

task :default => :test

begin
  require 'jeweler'

  # We're not putting VERSION or VERSION.yml in the root,
  # so we have to help Jeweler find our version.
  $LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
  require 'rip/version'

  Rip::Version.instance_eval do
    def refresh
    end
  end

  class Jeweler
    def version_helper
      Rip::Version
    end

    def version_exists?
      true
    end
  end

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rip"
    gemspec.summary = "Rip: Ruby's Intelligent Packaging"
    gemspec.email = "chris@ozmm.org"
    gemspec.homepage = "http://hellorip.com"
    gemspec.description = "Rip: Ruby's Intelligent Packaging"
    gemspec.authors = ["Chris Wanstrath"]
    gemspec.extensions = ["ext/extconf.rb"]
    gemspec.executables = ['']
    gemspec.has_rdoc = false
    gemspec.extra_rdoc_files = ['']
  end
rescue LoadError
  puts "Jeweler not available."
  puts "Install it with: rip install technicalpickles-jeweler"
end
