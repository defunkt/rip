require 'test/unit'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'rip'
require 'fileutils'

class Test::Unit::TestCase
  include FileUtils

  # Asserts that `haystack` includes `needle`.
  def assert_includes(needle, haystack, message = nil)
    message = build_message message, '<?> is not in <?>.', needle, haystack
    assert_block message do
      haystack.include? needle
    end
  end

  # Asserts that `haystack` does not include `needle`.
  def assert_not_includes(needle, haystack, message = nil)
    message = build_message message, '<?> is in <?>.', needle, haystack
    assert_block message do
      !haystack.include? needle
    end
  end

  # Shortcut for running the `rip` command in a subprocess. Returns
  # STDOUT as a string. Pass it what you would normally pass `rip` on
  # the command line, e.g.
  #
  # shell: rip create github
  #  test: rip("create github")
  #
  # If a block is given it will be run in the child process before
  # execution begins. You can use this to monkeypatch or fudge the
  # environment before running `rip`.
  def rip(subcommand, *args)
    parent_read, child_write = IO.pipe

    fork do
      yield if block_given?
      $stdout.reopen(child_write)
      $stderr.reopen(child_write)
      ENV['PATH'] = "bin/:#{ENV['PATH']}"
      exec "rip-#{subcommand}", *args
    end

    child_write.close
    parent_read.read
  end
end
