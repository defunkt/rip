$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class UnpackTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super

  end

  test "unpacks git://" do
    cache = rip "fetch git://localhost/cijoe"
    out = rip "unpack #{cache}"
    target = "#{@ripdir}/.packages/cijoe-7dc61376d0d25d249f01db8e3fa5b8d4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "unpacks git:// with ref" do
    cache = rip "fetch git://localhost/cijoe"
    out = rip "unpack #{cache} 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-66d4e9bd5651a5d1b76df6d51eb54630"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "unpacks git:// with floating ref" do
    cache = rip "fetch git://localhost/rack"
    out = rip "unpack #{cache} master"
    target = "#{@ripdir}/.packages/rack-41d1cc3dd91106567938e473c5c1bbfa"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "unpack #{cache} rack-1.1"
    target = "#{@ripdir}/.packages/rack-2749f85b690184fefd07bc6f1240a87a"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "unpack #{cache} rack-0.4"
    target = "#{@ripdir}/.packages/rack-985b79109d3ffde301f757dd92f8e9e5"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
  end

  test "unpacks git:// with explict root path" do
    cache = rip "fetch git://localhost/rails"
    out = rip "unpack #{cache} /"
    target = "#{@ripdir}/.packages/rails-ca17c9c555d42e8e639470ee2be9aff3"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/activesupport/lib/active_support.rb")
    assert File.exist?("#{target}/actionpack/lib/action_controller.rb")
    assert File.exist?("#{target}/activerecord/lib/active_record.rb")
  end

  test "unpacks git:// with path" do
    cache = rip "fetch git://localhost/rails"
    out = rip "unpack #{cache} /activerecord"
    target = "#{@ripdir}/.packages/rails-dd74aeed5f9dfc46263339506c992f4e"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/active_record.rb")
  end

  test "unpacks git:// with nonexistent path" do
    cache = rip "fetch git://localhost/rails"
    out = rip "unpack #{cache} /merb"
    assert_equal "git://localhost/rails /merb does not exist", out.chomp
  end

  test "unpacks git:// with nonexistent ref" do
    cache = rip "fetch git://localhost/rails"
    out = rip "unpack #{cache} xyz"
    assert_equal "git://localhost/rails xyz could not be found", out.chomp
  end

  test "unpack git:// clears remotes" do
    cache = rip "fetch git://localhost/cijoe"
    out = rip "unpack #{cache}"
    target = "#{@ripdir}/.packages/cijoe-7dc61376d0d25d249f01db8e3fa5b8d4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '', `git remote`.chomp }
  end

  test "unpack git:// clears branches" do
    cache = rip "fetch git://localhost/cijoe"
    out = rip "unpack #{cache}"
    target = "#{@ripdir}/.packages/cijoe-7dc61376d0d25d249f01db8e3fa5b8d4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '* (no branch)', `git branch`.chomp }
  end

  test "unpack twice" do
    cache = rip "fetch git://localhost/cijoe"
    out = rip "unpack #{cache}"
    target = "#{@ripdir}/.packages/cijoe-7dc61376d0d25d249f01db8e3fa5b8d4"
    assert_equal target, out.chomp

    out = rip "unpack #{cache}"
    target = "#{@ripdir}/.packages/cijoe-7dc61376d0d25d249f01db8e3fa5b8d4"
    assert_equal target, out.chomp
  end

  test "unpack gem" do
    cache = rip("fetch repl 0.1.0")
    out = rip("unpack #{cache}").chomp
    target = "#{@ripdir}/.packages/repl-7b5b351042bb6367328ea897d6c6b651"

    assert_equal target, out
    assert File.directory?(target)
  end

  test "unpack git@"

  test "unpack hg"

  test "unpack bzr"

  test "unpack http tar.gz"

  test "unpack http tar.bz"

  test "unpack svn"

  test "unpack dependencies" do
    cache = rip "fetch git://localhost/cijoe"
    out = rip "unpack #{cache}"
    assert_equal "cijoe", File.basename(out).split('-', 2)[0]

    out = rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = out.map { |f| File.basename(f).split('-', 2)[0] }
    assert_equal %w( rack sinatra tinder choice ).sort, fetched.sort
  end
end
