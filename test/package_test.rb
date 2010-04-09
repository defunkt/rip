$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PackageTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super
  end

  test "package git://" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "package git:// with ref" do
    out = rip "package git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-424ead3b3ff8b3bfc56780c79b027c21"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "package git:// with floating ref" do
    out = rip "package git://localhost/rack master"
    target = "#{@ripdir}/.packages/rack-dcd7e5a5c9005603446721d8d5226f96"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "package git://localhost/rack rack-1.1"
    target = "#{@ripdir}/.packages/rack-4219275757b34b94d4f1146d0d7a9802"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "package git://localhost/rack rack-0.4"
    target = "#{@ripdir}/.packages/rack-985b79109d3ffde301f757dd92f8e9e5"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
  end

  test "fech git:// with explict root path" do
    out = rip "package git://localhost/rails /"
    target = "#{@ripdir}/.packages/rails-1030698f9aa6e31414934c7fe4f4eee3"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/activesupport/lib/active_support.rb")
    assert File.exist?("#{target}/actionpack/lib/action_controller.rb")
    assert File.exist?("#{target}/activerecord/lib/active_record.rb")
  end

  test "package git:// with path" do
    out = rip "package git://localhost/rails /activerecord"
    target = "#{@ripdir}/.packages/rails-27f688b1f08408fd3e20626c4c048a4f"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/active_record.rb")
  end

  test "package git:// with nonexistent path" do
    out = rip "package git://localhost/rails /merb"
    assert_equal "git://localhost/rails /merb does not exist", out.chomp
  end

  test "package git:// with nonexistent ref" do
    out = rip "package git://localhost/rails xyz"
    assert_equal "git://localhost/rails xyz could not be found", out.chomp
  end

  test "package git:// clears remotes" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '', `git remote`.chomp }
  end

  test "package git:// clears branches" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '* (no branch)', `git branch`.chomp }
  end

  test "package twice" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp

    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"
    assert_equal target, out.chomp
  end

  test "package gem" do
    out = rip("package repl 0.1.0").chomp
    target = "#{@ripdir}/.packages/repl-7b5b351042bb6367328ea897d6c6b651"
    assert_equal target, out
    assert File.directory?(target)
  end

  test "package git@"

  test "package hg"

  test "package bzr"

  test "package http tar.gz"

  test "package http tar.bz"

  test "package svn"

  test "package dependencies" do
    out = rip "package git://localhost/cijoe"
    assert_equal "cijoe", File.basename(out).split('-', 2)[0]

    out = rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = out.map { |f| File.basename(f).split('-', 2)[0] }
    assert_equal %w( rack sinatra tinder choice ).sort, fetched.sort
  end
end
