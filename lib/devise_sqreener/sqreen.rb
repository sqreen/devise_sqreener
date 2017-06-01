require 'net/http'
module DeviseSqreener
  # sqreen an email of ip
  class Sqreen
    BASE_URL = 'https://api.sqreen.io/v1/%s/%s'.freeze

    attr_accessor :sqreen_api_token

    def initialize(token)
      self.sqreen_api_token = token
    end

    # Sqreen an email address
    # @param [String] email address to sqreen
    # @return [String, nil] nil (on any error) or the metadata hash
    def sqreen_email(email)
      sqreen(:emails, email)
    end

    # Sqreen an ip address
    # @param [String] ip address to sqreen
    # @return [] nil (on any error) or the metadata hash
    def sqreen_ip(ip)
      sqreen(:ips, ip)
    end

    protected

    def sqreen(kind, value)
      uri = URI(format(BASE_URL, kind, value))
      response = Net::HTTP.start(uri.hostname, uri.port,
                                 :use_ssl => uri.scheme == 'https') do |http|
        http.request_get(uri, 'x-api-key' => sqreen_api_token.to_s)
      end

      handle_response(kind, value, response)
    end

    def handle_response(kind, value, response)
      case response
      when Net::HTTPSuccess then
        return JSON.load(response.body)
      else
        Rails.logger.debug do
          "Cannot sqreen #{kind} #{value} #{response.inspect}"
        end
        nil
      end
    end
  end
end
