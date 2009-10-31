$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'
require 'stringio'

context "Rip::UI" do
  setup do
    @output = ''
    @ui = Rip::UI.new(StringIO.new(@output))
  end

  test 'puts message' do
    @ui.puts 'hello'
    assert_equal 'hello', @output.chomp
  end

  test 'empty puts' do
    @ui.puts
    assert_equal "\n", @output
  end

  test 'prepends "rip: " to abort message' do
    begin
      old = Kernel.method(:abort)
      class << Kernel; def abort(msg); msg end end
      assert_equal "rip: goodbye", @ui.abort("goodbye")
    ensure
      class << Kernel; self end.class_eval { define_method(:abort, old) }
    end
  end

  test 'prepends "rip: " to exit message' do
    begin
      old = Kernel.method(:exit)
      class << Kernel; def exit; "exiting"; end end
      
      assert_equal "exiting", @ui.exit("goodbye")
      assert_equal "rip: goodbye\n", @output
    ensure
      class << Kernel; self end.class_eval { define_method(:exit, old) }
    end
  end
  
  test "does not perform actions when no IO given" do
    ui = Rip::UI.new
    ui.puts 'this should not show up'
    ui.abort 'this should not abort'
  end
end
