$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context "Creating a ripenv" do
  setup do
    stub_fileutils!

    @active_dir = File.join(Rip.dir, 'active')
    @name = 'new_env'
    @ripenv = File.join(Rip.dir, @name)
    assert !File.exists?(@ripenv)
  end

  test "creates the directories on disk" do
    mock_fileutils!

    FileUtils.expects(:mkdir_p).with(File.join(@ripenv, 'bin'))
    FileUtils.expects(:mkdir_p).with(File.join(@ripenv, 'lib'))
    Rip::Env.create(@name)
  end

  test "confirms creation" do
    assert_equal "created new_env", Rip::Env.create(@name)
  end

  test "fails if the ripenv exists" do
    assert_equal "base exists", Rip::Env.create('base')
  end

  test "switches to the new ripenv" do
    Rip::Env.expects(:use).with(@name)
    Rip::Env.create(@name)
  end
end

context "Using a ripenv" do
  setup do
    stub_fileutils!

    @active_dir = File.join(Rip.dir, 'active')
    @name = 'new_env'
    @ripenv = File.join(Rip.dir, @name)
    @base = 'base'
    @old_ripenv = File.join(Rip.dir, @base)
  end

  test "switches the active symlink" do
    mock_fileutils!
    File.expects(:exists?).with(@ripenv).returns(true)

    FileUtils.expects(:ln_s).with(@ripenv, @active_dir)
    Rip::Env.use(@name)
  end

  test "confirms the change" do
    File.expects(:exists?).with(@ripenv).returns(true)

    assert_equal "using #{@name}", Rip::Env.use(@name)
  end

  test "fails if the new env doesn't exist" do
    assert_equal "fake doesn't exist", Rip::Env.use("fake")
  end
end

context "Deleting a ripenv" do
  setup do
    stub_fileutils!

    @name = "some_env"
    @ripenv = File.join(Rip.dir, @name)

    File.stubs(:exists?).with(@ripenv).returns(true)
  end

  test "removes the ripenv" do
    mock_fileutils!
    FileUtils.expects(:rm_rf).with(@ripenv)
    Rip::Env.delete(@name)
  end

  test "confirms removal" do
    assert_equal "deleted #{@name}", Rip::Env.delete(@name)
  end

  test "fails if it's the active ripenv" do
    assert_equal "can't delete active environment", Rip::Env.delete('base')
  end

  test "fails if it doesn't exist" do
    File.expects(:exists?).with(@ripenv).returns(false)
    assert_equal "can't find #{@name}", Rip::Env.delete(@name)
  end
end
