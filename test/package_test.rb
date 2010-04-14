$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PackageTest < Rip::Test
  def setup
    start_git_daemon
    start_gem_daemon
    super
  end

  test "fetch git:// package" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-8867c4b739942fd9bf7b60125c1c81e4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// package with ref" do
    out = rip "package git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-8867c4b739942fd9bf7b60125c1c81e4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// package with floating ref" do
    out = rip "package git://localhost/rack master"
    target = "#{@ripdir}/.packages/rack-63b18a3aa5a4b6e435765c1e6adb33a4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "package git://localhost/rack rack-1.1"
    target = "#{@ripdir}/.packages/rack-63b18a3aa5a4b6e435765c1e6adb33a4"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "package git://localhost/rack rack-0.4"
    target = "#{@ripdir}/.packages/rack-63b18a3aa5a4b6e435765c1e6adb33a4"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
  end

  test "fetch git:// package with explict root path" do
    out = rip "package git://localhost/rails /"
    target = "#{@ripdir}/.packages/rails-5c9f9d69f6a4a70089825598f16a3756"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/activesupport/lib/active_support.rb")
    assert File.exist?("#{target}/actionpack/lib/action_controller.rb")
    assert File.exist?("#{target}/activerecord/lib/active_record.rb")
  end

  test "fetch git:// package with path" do
    out = rip "package git://localhost/rails /activerecord"
    target = "#{@ripdir}/.packages/rails-5c9f9d69f6a4a70089825598f16a3756"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/active_record.rb")
  end

  test "fetch git:// package with nonexistent path" do
    out = rip "package git://localhost/rails /merb"
    assert_equal "#{cache.chomp} /merb does not exist", out.chomp
  end

  test "fetch git:// package with nonexistent ref" do
    out = rip "package git://localhost/rails xyz"
    assert_equal "#{cache.chomp} xyz could not be found", out.chomp
  end

  test "fetch git:// package clears remotes" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-8867c4b739942fd9bf7b60125c1c81e4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '', `git remote`.chomp }
  end

  test "fetch git:// package clears branches" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-8867c4b739942fd9bf7b60125c1c81e4"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '* (no branch)', `git branch`.chomp }
  end

  test "fetch package twice" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-8867c4b739942fd9bf7b60125c1c81e4"
    assert_equal target, out.chomp

    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-8867c4b739942fd9bf7b60125c1c81e4"
    assert_equal target, out.chomp
  end

  test "fetch gem package" do
    out = rip("package repl 0.1.0").chomp
    target = "#{@ripdir}/.packages/repl-aaf6a5a06fc372b6c49bb5104839b36f"

    assert_equal target, out
    assert File.directory?(target)
  end

  test "fetch git@ package"

  test "fetch hg package"

  test "fetch bzr package"

  test "fetch http tar.gz package"

  test "fetch http tar.bz package"

  test "fetch svn package"

  test "fetch package with dependencies" do
    out = rip "package git://localhost/cijoe"
    assert_equal "cijoe", File.basename(out).split('-', 2)[0]

    out = rip "fetch-dependencies #{out.chomp}/deps.rip"
    fetched = out.map { |f| File.basename(f).split('-', 2)[0] }
    assert_equal %w( rack sinatra tinder choice ).sort, fetched.sort
  end

  test "writes package.rip" do
    out = rip "package git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-df5953e0bdf7d0c218632bb5d08cb458"

    assert File.exist?("#{target}/cijoe.rip")
    assert_equal "git://localhost/cijoe master\n",
      File.read("#{target}/cijoe.rip")
  end
end
