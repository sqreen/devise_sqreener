require 'helper'
require 'devise_enricher/model'
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
  devise :database_authenticatable, :enrichable
end

class TrackableUser < ActiveRecord::Base
  devise :database_authenticatable, :trackable, :enrichable
end

class TestModel < Minitest::Test
  def test_model
    assert_equal(%i(enriched_email),
                 Devise::Models::Enrichable.required_fields(User))
    assert_equal(%i(enriched_email current_sign_in_ip last_sign_in_ip
                    current_enriched_sign_in_ip last_enriched_sign_in_ip),
                 Devise::Models::Enrichable.required_fields(TrackableUser))
  end

  def test_current_enriched_ip_address
    user = User.new
    assert_nil user.current_enriched_ip_address
    user.current_ip_address = '10.0.0.1'
    mock = Minitest::Mock.new
    mock.expect(:enrich_ip, { 'test' => 1 }, ['10.0.0.1'])
    DeviseEnricher::Enrich.stub :new, mock do
      refute_nil user.current_enriched_ip_address
    end
    mock.verify
  end

  def test_current_enriched_email
    user = User.new
    assert_nil user.current_enriched_email
    user.email = 'test@test.com'
    mock = Minitest::Mock.new
    mock.expect(:enrich_email, { 'test' => 1 }, ['test@test.com'])
    DeviseEnricher::Enrich.stub :new, mock do
      refute_nil user.current_enriched_email
    end
    mock.verify
  end

  def test_tracked_fields
    user = User.new
    assert_nil user.update_tracked_fields(ActionDispatch::Request.new({}))
    user = TrackableUser.new
    user.current_enriched_sign_in_ip = 'test'
    user.current_ip_address = nil
    user.update_tracked_fields(ActionDispatch::Request.new({}))
    assert_nil user.current_enriched_sign_in_ip
    assert_equal 'test', user.last_enriched_sign_in_ip
  end

  def test_enrich_block_sign_in?
    user = User.new
    refute_equal :forbidden, user.inactive_message
    refute user.enrich_block_sign_in?
    Devise.enrich_block_sign_in = -> (*_) { true }
    assert user.enrich_block_sign_in?
    assert_equal :forbidden, user.inactive_message
  ensure
    Devise.enrich_block_sign_in = nil
  end

  def test_enrich_block_sign_up?
    user = User.new(:email => 'test@test.com')
    refute user.enrich_block_sign_up?
    user.email = 'test@test.com'
    mock = Minitest::Mock.new
    mock.expect(:enrich_email, { 'test' => 1 }, ['test@test.com'])
    DeviseEnricher::Enrich.stub :new, mock do
      Devise.enrich_block_sign_up = -> (*_) { true }
      assert user.enrich_block_sign_up?
      refute_nil user.errors[:base]
      refute user.save
    end
  ensure
    Devise.enrich_block_sign_up = nil
  end

  def test_enrich_email
    user = User.new(:email => 'test@test.com')
    mock = Minitest::Mock.new
    mock.expect(:enrich_email, { 'test' => 1 }, ['test@test.com'])
    DeviseEnricher::Enrich.stub :new, mock do
      assert user.save
      assert_equal({ 'test' => 1 }, user.enriched_email)
    end
  end
end
