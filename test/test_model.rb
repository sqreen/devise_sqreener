require 'helper'
require 'devise_sqreener/model'
require 'devise/orm/active_record'
require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:',
  :pool => 5
)
ActiveRecord::Migrator.migrate(File.expand_path('../db_migrate/', __FILE__))

class User < ActiveRecord::Base
  devise :database_authenticatable, :sqreenable
end

class TrackableUser < ActiveRecord::Base
  devise :database_authenticatable, :trackable, :sqreenable
end

class TestModel < Minitest::Test
  def test_model
    assert_equal(%i(sqreened_email),
                 Devise::Models::Sqreenable.required_fields(User))
    assert_equal(%i(sqreened_email current_sign_in_ip last_sign_in_ip
                    current_sqreened_sign_in_ip last_sqreened_sign_in_ip),
                 Devise::Models::Sqreenable.required_fields(TrackableUser))
  end

  def test_current_sqreened_ip_address
    user = User.new
    assert_nil user.current_sqreened_ip_address
    user.current_ip_address = '10.0.0.1'
    mock = Minitest::Mock.new
    mock.expect(:sqreen_ip, {'test' => 1 }, ['10.0.0.1'])
    DeviseSqreener::Sqreen.stub :new, mock do
      refute_nil user.current_sqreened_ip_address
    end
    mock.verify
  end

  def test_current_sqreened_email
    user = User.new
    assert_nil user.current_sqreened_email
    user.email = 'test@test.com'
    mock = Minitest::Mock.new
    mock.expect(:sqreen_email, {'test' => 1 }, ['test@test.com'])
    DeviseSqreener::Sqreen.stub :new, mock do
      refute_nil user.current_sqreened_email
    end
    mock.verify
  end

  def test_tracked_fields
    user = User.new
    assert_nil user.update_tracked_fields(ActionDispatch::Request.new({}))
    user = TrackableUser.new
    user.current_sqreened_sign_in_ip = 'test'
    user.current_ip_address = nil
    user.update_tracked_fields(ActionDispatch::Request.new({}))
    assert_nil user.current_sqreened_sign_in_ip
    assert_equal 'test', user.last_sqreened_sign_in_ip
  end

  def test_sqreen_block_sign_in?
    user = User.new
    refute_equal :forbidden, user.inactive_message
    refute user.sqreen_block_sign_in?
    Devise.sqreen_block_sign_in = -> (*_) { true }
    assert user.sqreen_block_sign_in?
    assert_equal :forbidden, user.inactive_message
  ensure
    Devise.sqreen_block_sign_in = nil
  end

  def test_sqreen_block_sign_up?
    user = User.new(:email => 'test@test.com')
    refute user.sqreen_block_sign_up?
    user.email = 'test@test.com'
    mock = Minitest::Mock.new
    mock.expect(:sqreen_email, {'test' => 1 }, ['test@test.com'])
    DeviseSqreener::Sqreen.stub :new, mock do
      Devise.sqreen_block_sign_up = -> (*_) { true }
      assert user.sqreen_block_sign_up?
      refute_nil user.errors[:base]
      refute user.save
    end
  ensure
    Devise.sqreen_block_sign_up = nil
  end

  def test_sqreen_email
    user = User.new(:email => 'test@test.com')
    mock = Minitest::Mock.new
    mock.expect(:sqreen_email, {'test' => 1 }, ['test@test.com'])
    DeviseSqreener::Sqreen.stub :new, mock do
      assert user.save
      assert_equal({ 'test' => 1 }, user.sqreened_email)
    end
  end
end
