require 'net/http'
module DeviseEnricher
  # enrich an email of ip
  class Enrich
    BASE_URL = 'https://api.sqreen.io/v1/%s/%s'.freeze

    attr_accessor :sqreen_enrich_token

    def initialize(token)
      self.sqreen_enrich_token = token
    end

    # Enrich an email address
    # @param [String] email address to enrich
    # @return [String, nil] nil (on any error) or the metadata hash
    def enrich_email(email)
      enrich(:emails, email)
    end

    # Enrich an ip address
    # @param [String] ip address to enrich
    # @return [] nil (on any error) or the metadata hash
    def enrich_ip(ip)
      enrich(:ips, ip)
    end

    protected

    def enrich(kind, value)
      uri = URI(format(BASE_URL, kind, value))
      response = Net::HTTP.start(uri.hostname, uri.port,
                                 :use_ssl => uri.scheme == 'https') do |http|
        http.request_get(uri, 'x-api-key' => sqreen_enrich_token.to_s)
      end

      handle_response(kind, value, response)
    end

    def handle_response(kind, value, response)
      case response
      when Net::HTTPSuccess then
        return JSON.load(response.body)
      else
        Rails.logger.debug do
          "Cannot enrich #{kind} #{value} #{response.inspect}"
        end
        nil
      end
    end
  end
end
