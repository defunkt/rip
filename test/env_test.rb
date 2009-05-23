$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'test_helper'

context "Creating a ripenv" do
  setup_with_fs do
    @active_dir = File.join(Rip.dir, 'active')
    @name = 'new_env'
    @ripenv = File.join(Rip.dir, @name)
    assert !File.exists?(@ripenv)
  end

  test "creates the directories on disk" do
    Rip::Env.create(@name)
    assert File.exists?(File.join(@ripenv, 'bin'))
    assert File.exists?(File.join(@ripenv, 'lib'))
  end

  test "confirms creation" do
    assert_equal "created new_env", Rip::Env.create(@name)
  end

  test "fails if the ripenv exists" do
    assert_equal "base exists", Rip::Env.create('base')
  end

  test "switches to the new ripenv" do
    Rip::Env.create(@name)
    assert_equal @name, Rip::Env.active
  end
end

context "Using a ripenv" do
  setup_with_fs do
    @active_dir = File.join(Rip.dir, 'active')
    @name = 'other'
    @ripenv = File.join(Rip.dir, @name)
    @base = 'base'
    @old_ripenv = File.join(Rip.dir, @base)
  end

  test "switches the active symlink" do
    Rip::Env.use(@name)
    assert_equal @name, Rip::Env.active
  end

  test "confirms the change" do
    assert_equal "using #{@name}", Rip::Env.use(@name)
  end

  test "fails if the new env doesn't exist" do
    assert_equal "fake doesn't exist", Rip::Env.use("fake")
  end
end

context "Deleting a ripenv" do
  setup_with_fs do
    @name = "other"
    @ripenv = File.join(Rip.dir, @name)
  end

  test "removes the ripenv" do
    assert File.exists?(@ripenv)
    Rip::Env.delete(@name)
    assert !File.exists?(@ripenv)
  end

  test "confirms removal" do
    assert_equal "deleted #{@name}", Rip::Env.delete(@name)
  end

  test "fails if it's the active ripenv" do
    assert_equal "can't delete active environment", Rip::Env.delete('base')
  end

  test "fails if it doesn't exist" do
    name = 'fake_env'
    assert_equal "can't find #{name}", Rip::Env.delete(name)
  end
end

context "Listing ripenvs" do
  setup_with_fs do
    @ripenvs = Rip::Env.list
  end

  test "prints ripenvs" do
    assert_equal 2, @ripenvs.split(' ').size
    assert @ripenvs.include?('base')
  end

  test "ignores the active symlink" do
    assert !@ripenvs.include?('active')
  end

  test "ignores rip-* directories" do
    assert !@ripenvs.include?('rip-packages')
  end
end

context "Displaying the active ripenv" do
  setup_with_fs do
    # no setup
  end

  test "works" do
    assert_equal 'base', Rip::Env.active
  end

  test "works across env changes" do
    Rip::Env.use('other')
    assert_equal 'other', Rip::Env.active
  end
end
