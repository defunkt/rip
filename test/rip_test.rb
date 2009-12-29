$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class RipTest < Test::Unit::TestCase
  def setup
    ripdir = File.expand_path(File.dirname(__FILE__) + "/ripdir")
    rm_rf ripdir
    ENV['RIPDIR'] = @ripdir = ripdir
    rip "setup"
  end

  test "setup" do
    rm_rf @ripdir
    rip "setup"
    assert File.exists?("#{@ripdir}/active")
    assert File.symlink?("#{@ripdir}/active")
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end

  test "create ripenv" do
    rip "create blah"
    assert_equal "#{@ripdir}/blah", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/blah")
  end

  test "create existing ripenv" do
  end

  test "use ripenv" do
    rip "create blah"
    rip "use base"
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
  end

  test "use fake ripenv" do
    out = rip "use not-real"
    assert_includes "Can't find", out
  end

  test "shell" do
    output = rip "shell"
    assert_includes "RIPDIR=", output
  end
end
