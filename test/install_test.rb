require 'helper'

class InstallTest < Rip::Test
  def setup
    ENV['RIPRPG'] = '0'
    super
  end

  test "install cijoe-deps.rip" do
    out = rip "install #{fixture('cijoe-deps.rip')}"
    assert_exited_successfully out

    assert File.exist?("#{@ripdir}/base/bin/cijoe")
    assert File.exist?("#{@ripdir}/base/lib/cijoe.rb")
    assert File.exist?("#{@ripdir}/base/lib/cijoe/build.rb")
  end

  test "install repl gem" do
    out = rip "install repl"
    assert_exited_successfully out

    assert_equal "installed repl (0.1.0)", out.strip

    assert File.exist?("#{@ripdir}/base/bin/repl")
    assert File.exist?("#{@ripdir}/base/man/man1/repl.1")
  end

  test "pretend" do
    out = rip("install -p #{fixture('cijoe-deps.rip')}")
    assert_equal <<packages, out, out
git://localhost/cijoe 04419882877337e70ac572a36d25416b0da9ba0f
git://localhost/tinder.git 1.2.0
git://localhost/sinatra.git 0.9.4
git://localhost/rack.git 1.0
git://localhost/choice.git 8b12556493c86b07ff3efc0fa31f0981b5d1ff83
packages
  end

  test "only" do
    out = rip("install -p -o #{fixture('cijoe-deps.rip')}")
    assert_equal <<packages, out, out
git://localhost/cijoe 04419882877337e70ac572a36d25416b0da9ba0f
packages
  end

  test "know about versions" do
    out = rip "install repl 0.100.0"
    assert_exited_with_error out
  end
end
