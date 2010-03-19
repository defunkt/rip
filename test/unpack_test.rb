$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class UnpackTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super
  end

  test "unpack git://" do
    out = rip "unpack git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "unpack git:// with ref" do
    out = rip "unpack git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-424ead3b3ff8b3bfc56780c79b027c21"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "unpack git:// with floating ref" do
    out = rip "unpack git://localhost/rack master"
    target = "#{@ripdir}/.packages/rack-dcd7e5a5c9005603446721d8d5226f96"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "unpack git://localhost/rack rack-1.1"
    target = "#{@ripdir}/.packages/rack-4219275757b34b94d4f1146d0d7a9802"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "unpack git://localhost/rack rack-0.4"
    target = "#{@ripdir}/.packages/rack-985b79109d3ffde301f757dd92f8e9e5"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
  end

  test "fech git:// with explict root path" do
    out = rip "unpack git://localhost/rails /"
    target = "#{@ripdir}/.packages/rails-1030698f9aa6e31414934c7fe4f4eee3"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/activesupport/lib/active_support.rb")
    assert File.exist?("#{target}/actionpack/lib/action_controller.rb")
    assert File.exist?("#{target}/activerecord/lib/active_record.rb")
  end

  test "unpack git:// with path" do
    out = rip "unpack git://localhost/rails /activerecord"
    target = "#{@ripdir}/.packages/rails-27f688b1f08408fd3e20626c4c048a4f"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/active_record.rb")
  end

  test "unpack git:// with nonexistent path" do
    out = rip "unpack git://localhost/rails /merb"
    assert_equal "git://localhost/rails /merb does not exist", out.chomp
  end

  test "unpack git:// with nonexistent ref" do
    out = rip "unpack git://localhost/rails xyz"
    assert_equal "git://localhost/rails xyz could not be found", out.chomp
  end

  test "unpack git:// clears remotes" do
    out = rip "unpack git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '', `git remote`.chomp }
  end

  test "unpack git:// clears branches" do
    out = rip "unpack git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '* (no branch)', `git branch`.chomp }
  end

  test "unpack twice" do
    out = rip "unpack git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp

    out = rip "unpack git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
  end

  test "unpack gem" do
    out = rip("unpack repl 0.1.0").chomp
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
    out = rip "unpack git://localhost/cijoe"
    rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = Dir["#{@ripdir}/.packages/*"].map do |f|
      File.basename(f).split('-', 2)[0]
    end
    assert_equal %w( cijoe rack sinatra tinder choice ).sort, fetched.sort
  end
end
