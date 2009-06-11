$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

load File.expand_path(File.dirname(__FILE__) + '/../bin/rip')

context 'Parsing command line args' do
  test "works" do
    assert_equal ["install", { :f => true }, []], parse_args(%w( install -f ))
    assert_equal ["install", { :f => "force" }, []], parse_args(%w( install -f=force ))
    assert_equal ["install", { :f => true }, [ "force", "name" ]], parse_args(%w( install -f force name ))
    assert_equal ["install", {}, [ "something" ]], parse_args(%w( install something ))
  end
end
