$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class RipTest < Test::Unit::TestCase
  def setup
    ripdir = File.expand_path(File.dirname(__FILE__) + "/ripdir")
    rm_rf ripdir
    mkdir_p ripdir
    ENV['RIPDIR'] = @ripdir = ripdir
  end

  def test_setup
    rip "setup"
    assert File.exists?("#{@ripdir}/active")
    assert File.symlink?("#{@ripdir}/active")
    assert_equal "#{@ripdir}/base", File.readlink("#{@ripdir}/active")
    assert File.exists?("#{@ripdir}/base")
  end

  def test_shell
    output = rip "shell"
    assert_includes "RIPDIR=", output
  end
end
