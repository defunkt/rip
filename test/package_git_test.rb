$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PackageGitTest < Rip::Test
  def setup
    start_git_daemon
    super
  end

  test "can't handle unknown protocol" do
    out = rip "package-git rack"
    assert_exited_with_error out
  end

  test "fetch git:// package" do
    out = rip "package-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// package with ref" do
    out = rip "package-git git://localhost/cijoe 28e583afc7c3153860e3b425fe4e4179f951835f"
    target = "#{@ripdir}/.packages/cijoe-5e096d4e73f7b9281514ccfb6667ec94"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/cijoe/version.rb")
  end

  test "fetch git:// package with floating ref" do
    out = rip "package-git git://localhost/rack master"
    target = "#{@ripdir}/.packages/rack-c3d5bb01b7e8e3cf08139d8c997239ae"

    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "package-git git://localhost/rack rack-1.1"
    target = "#{@ripdir}/.packages/rack-d09f0f92cbc9fd9445818a3f3677854e"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert File.exist?("#{target}/lib/rack/methodoverride.rb")

    out = rip "package-git git://localhost/rack rack-0.4"
    target = "#{@ripdir}/.packages/rack-30a09c76441ee7f3cc320aae57e9c99e"
    assert_equal target, out.chomp
    assert File.directory?(target)
    assert !File.exist?("#{target}/lib/rack/methodoverride.rb")
  end

  test "fetch git:// package with nonexistent ref" do
    out = rip "package-git git://localhost/rails xyz"
    assert_equal "git://localhost/rails xyz could not be found", out.chomp
  end

  test "fetch git:// package clears remotes" do
    out = rip "package-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '', `git remote`.chomp }
  end

  test "fetch git:// package clears branches" do
    out = rip "package-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f"

    assert_equal target, out.chomp
    assert File.directory?(target)
    cd(target) { assert_equal '* (no branch)', `git branch`.chomp }
  end

  test "fetch package twice" do
    out = rip "package-git git://localhost/cijoe"
    assert_exited_successfully out

    out = rip "package-git git://localhost/cijoe"
    assert_exited_successfully out
  end

  test "writes package.rip" do
    out = rip "package-git git://localhost/cijoe"
    target = "#{@ripdir}/.packages/cijoe-20053386165d0ace45a91cd03c9ea31f"

    assert_equal target, out.chomp
    assert File.exist?("#{target}/metadata.rip")
    assert_equal "git://localhost/cijoe e8a53aac256665563cf6bb27c04788ce758424ac\n",
      File.read("#{target}/metadata.rip")
  end
end
