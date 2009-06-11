$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context 'Parsing command line args' do
  setup do
    Rip::Commands.send(:public, :parse_args)
  end

  test "works" do
    assert_equal ["install", { :f => true }, []], Rip::Commands.parse_args(%w( install -f ))
    assert_equal ["install", { :f => "force" }, []], Rip::Commands.parse_args(%w( install -f=force ))
    assert_equal ["install", { :f => true }, [ "force", "name" ]], Rip::Commands.parse_args(%w( install -f force name ))
    assert_equal ["install", {}, [ "something" ]], Rip::Commands.parse_args(%w( install something ))
  end
end
