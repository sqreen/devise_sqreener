require 'helper'
require 'devise_enricher/enrich'

class TestEnrich < Minitest::Test
  def setup
    Rails.logger = Logger.new(nil)
  end

  def test_enrich_ip
    stub_request(:get, 'https://api.sqreen.io/enrich/ip/8.8.8.8').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token'
           }).
      to_return(:status => 200, :body => '{"value": 1}', :headers => {})
    assert_equal({ 'value' => 1 },
                 DeviseEnricher::Enrich.new('token').enrich_ip('8.8.8.8'))
  end

  def test_enrich_ip_invalid_token
    stub_request(:get, 'https://api.sqreen.io/enrich/ip/8.8.8.8').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token2'
           }).
      to_return(:status => 403, :body => '', :headers => {})
    assert_nil(DeviseEnricher::Enrich.new('token2').enrich_ip('8.8.8.8'))
  end

  def test_enrich_email
    stub_request(:get, 'https://api.sqreen.io/enrich/email/test@test.com').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token'
           }).
      to_return(:status => 200, :body => '{"value": 1}', :headers => {})
    assert_equal({ 'value' => 1 },
                 DeviseEnricher::Enrich.new('token').enrich_email('test@test.com'))
  end

  def test_enrich_email_invalid_token
    stub_request(:get, 'https://api.sqreen.io/enrich/email/test@test.com').
      with(:headers => {
             'Accept' => '*/*',
             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Host' => 'api.sqreen.io', 'User-Agent' => 'Ruby',
             'X-Api-Key' => 'token2'
           }).
      to_return(:status => 403, :body => '', :headers => {})
    assert_nil(DeviseEnricher::Enrich.new('token2').enrich_email('test@test.com'))
  end
end
