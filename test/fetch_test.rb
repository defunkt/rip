$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class FetchTest < Rip::Test
  def setup
    start_git_daemon
    super
  end

  test "fetch git://" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-4daea8c1f26a894145eaf3e5c3015c58"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// with ref" do
    out = rip "fetch git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-414249968732aa0fc53b7f7ce94b84c8"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// with floating ref" do
    # Expose rack branchs to git daemon
    system "echo 92f79ea8def92c3c2373b9ab5f5fa8e03aa7669d > test/fixtures/rack/.git/refs/heads/rack-0.4"
    system "echo e6ebd831978adc3172ad487be18affab940f3d4d > test/fixtures/rack/.git/refs/heads/rack-1.1"

    out = rip "fetch git://localhost/rack master"
    target = "#{@ripdir}/.packages/rack-a41744c571bebea931f89ab1e296fea4"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "fetch git://localhost/rack rack-1.1"
    target = "#{@ripdir}/.packages/rack-b13505f2d998e179129895b2c400816d"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "fetch git://localhost/rack rack-0.4"
    target = "#{@ripdir}/.packages/rack-80b6452b78dbf9c69d875f1305adfcb4"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
  end

  test "fetch twice" do
    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-4daea8c1f26a894145eaf3e5c3015c58"
    assert_equal target, out.chomp

    out = rip "fetch git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-4daea8c1f26a894145eaf3e5c3015c58"
    assert_equal target, out.chomp
  end

  test "fetch git@"

  test "fetch hg"

  test "fetch bzr"

  test "fetch http tar.gz"

  test "fetch http tar.bz"

  test "fetch svn"

  test "fetch dependencies" do
    out = rip "fetch git://localhost/cijoe"
    rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = Dir["#{@ripdir}/.packages/*"].map do |f|
      File.basename(f).split('-', 2)[0]
    end
    assert_equal %w( cijoe rack sinatra tinder choice ).sort, fetched.sort
  end
end
