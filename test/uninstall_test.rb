require 'helper'

class UninstallTest < Rip::Test
  def setup
    ENV['RIPRPG'] = '0'
    super
  end

  def rip_list
    rip("list-minimal").split("\n").map {|e| e[/^\S+/] }
  end

  test "uninstall cijoe-deps.rip" do
    rip "install #{fixture('cijoe-deps.rip')}"

    assert rip_list.include?('git://localhost/cijoe')
    assert File.exist?("#{@ripdir}/base/bin/cijoe")
    assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")

    out = rip "uninstall cijoe"

    assert_exited_successfully out
    assert_equal "cijoe (0441988287) uninstalled", out.chomp

    assert !rip_list.include?('git://localhost/cijoe')
    assert !File.exist?("#{@ripdir}/base/bin/cijoe")
    assert !File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert !File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")
  end

  test "uninstall repl gem" do
    rip "install repl"

    assert rip_list.include?('repl')
    assert File.exist?("#{@ripdir}/base/bin/repl")
    assert File.exist?("#{@ripdir}/base/man/man1/repl.1")

    out = rip "uninstall repl"

    assert_exited_successfully out
    assert_equal "repl (0.1.0) uninstalled", out.chomp

    assert !rip_list.include?('repl')
    assert !File.exist?("#{@ripdir}/base/bin/repl")
    assert !File.exist?("#{@ripdir}/base/man/man1/repl.1")
  end
end