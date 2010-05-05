require 'rip/version'

Gem::Specification.new do |s|
  s.name              = "rip"
  s.version           = Rip::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Take back your $LOAD_PATH"
  s.homepage          = "http://hellorip.com"
  s.email             = "chris@ozmm.org"
  s.authors           = [ "Chris Wanstrath", "Joshua Peek" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")

 s.executables       = %w( rip )
  s.description       = <<desc
rip creates and manages environments of packages. rip packages
may be created from RubyGems, git repositories, or more.
  Feed me.
desc
end
