require 'net/http'
module DeviseEnricher
  # enrich an email of ip
  class Enrich
    BASE_URL = 'https://api.sqreen.io/enrich/%s/%s'.freeze

    attr_accessor :sqreen_enrich_token

    def initialize(token)
      self.sqreen_enrich_token = token
    end

    def enrich_email(email)
      enrich(:email, email)
    end

    def enrich_ip(ip)
      enrich(:ip, ip)
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
