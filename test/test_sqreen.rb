require 'helper'
require 'devise_sqreener/sqreen'

class TestSqreen < Minitest::Test
  def setup
    Rails.logger = Logger.new(nil)
  end

  def test_sqreen_ip
    stub_request(:get, 'https://api.sqreen.io/v1/ips/8.8.8.8').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token'
           }).
      to_return(:status => 200, :body => '{"value": 1}', :headers => {})
    assert_equal({ 'value' => 1 },
                 DeviseSqreener::Sqreen.new('token').sqreen_ip('8.8.8.8'))
  end

  def test_sqreen_ip_invalid_token
    stub_request(:get, 'https://api.sqreen.io/v1/ips/8.8.8.8').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token2'
           }).
      to_return(:status => 403, :body => '', :headers => {})
    assert_nil(DeviseSqreener::Sqreen.new('token2').sqreen_ip('8.8.8.8'))
  end

  def test_sqreen_email
    stub_request(:get, 'https://api.sqreen.io/v1/emails/test@test.com').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token'
           }).
      to_return(:status => 200, :body => '{"value": 1}', :headers => {})
    assert_equal({ 'value' => 1 },
                 DeviseSqreener::Sqreen.new('token').sqreen_email('test@test.com'))
  end

  def test_sqreen_email_invalid_token
    stub_request(:get, 'https://api.sqreen.io/v1/emails/test@test.com').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token2'
           }).
      to_return(:status => 403, :body => '', :headers => {})
    assert_nil(DeviseSqreener::Sqreen.new('token2').sqreen_email('test@test.com'))
  end
end
