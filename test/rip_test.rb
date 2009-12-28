$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class RipTest < Test::Unit::TestCase
  def setup
    ripdir = File.expand_path(File.dirname(__FILE__) + "/ripdir")
    rm_rf ripdir
    ENV['RIPDIR'] = @ripdir = ripdir
    rip "setup"
  end

  def test_setup
    rm_rf @ripdir
    rip "setup"
    assert File.exists?("#{@ripdir}/active")
    assert File.symlink?("#{@ripdir}/active")
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end

  def test_env_create
    rip "create blah"
    assert_equal "#{@ripdir}/blah", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/blah")
  end

  def test_env_use
    rip "create blah"
    rip "use base"
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
  end

  def test_shell
    output = rip "shell"
    assert_includes "RIPDIR=", output
  end
end
