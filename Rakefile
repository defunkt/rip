task :default => :test

desc "Run the test suite."
task :test do 
  ruby "test/rip_test.rb"
end

desc "Installs Rip"
task :install do
  prefix = ENV['PREFIX'] || ENV['prefix'] || '/usr/local'
  bindir = ENV['BINDIR'] || ENV['bindir'] || "#{prefix}/bin"
  libdir = ENV['LIBDIR'] || ENV['libdir'] || "#{prefix}/lib"

  mkdir_p bindir
  Dir["bin/*"].each do |f|
    cp f, bindir, :preserve => true, :verbose => true
  end

  mkdir_p libdir
  Dir["lib/**/*.rb"].each do |f|
    cp f, libdir
  end
end
