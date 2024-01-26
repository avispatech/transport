# frozen_string_literal: true

require_relative "transport/version"
require "hashie"
require "oj" 
require "typhoeus"


module Transport
  class Error < StandardError; end
  
  class Base
    BASE_HEADERS = {
      'Content-Type' => 'application/json'
    }.freeze

    RESPONSE_LOGGING = ENV.fetch('TYPHOEUS_RESPONSE_LOGGING', 'LOG_RESPONSES')

    def self.get(url:, xheaders: nil, params: {}, body: nil)
      headers = xheaders.nil? ? BASE_HEADERS : BASE_HEADERS.merge(xheaders)
      request = ::Typhoeus::Request.new(url, method: :get, headers: headers, params: params, body: body)

      run request
    end

    def self.post(url:, body: nil, payload: {}, xheaders: nil, params: {})
      put_post(url: url,
               method: :post,
               xheaders: xheaders,
               params: params,
               body: body || Oj.generate(payload.deep_stringify_keys))
    end

    def self.put(url:, body: nil, payload: {}, xheaders: nil, params: {})
      put_post(url: url,
               method: :put,
               xheaders: xheaders,
               params: params,
               body: body || Oj.generate(payload.deep_stringify_keys))
    end

    def self.run(request)
      if RESPONSE_LOGGING == 'LOG_RESPONSES'
        Rails.logger.info "#{request.options[:method].upcase}ing to #{request.url}"
        Rails.logger.info request.options[:body]
      end
      response = commit request
      process response
    end

    def self.put_post(url:, body:, xheaders:, params:, method:)
      headers = xheaders.nil? ? BASE_HEADERS : BASE_HEADERS.merge(xheaders)
      request = ::Typhoeus::Request.new(url,
                                        method: method,
                                        body: body,
                                        headers: headers,
                                        params: params)
      Rails.logger.debug request.inspect if RESPONSE_LOGGING == 'LOG_RESPONSES'
      run request
    end

    def self.code_response(rsp, headers)
      response_code = rsp.options[:response_code]

      Rails.logger.debug rsp.options[:response_body] if response_code < 300
      {
        code: response_code,
        url: rsp.options[:effective_url],
        headers: headers,
        cookies: headers[:set_cookie],
        body: response_code < 300 ? formatted_body(rsp.options[:response_body]) : nil
      }
    end

    def self.formatted_body(body)
      return nil if body.nil?

      Oj.load(body)&.deep_symbolize_keys
    end

    def self.process(rsp)
      headers = process_headers(rsp.options[:response_headers])
      coded_response = code_response(rsp, headers)
      log_coded_response coded_response if RESPONSE_LOGGING == 'LOG_RESPONSES'
      Hashie::Mash.new coded_response
    end

    def self.log_coded_response(resp)
      Rails.logger.debug "Response from #{resp[:url]}" if RESPONSE_LOGGING == 'LOG_RESPONSES'

      resp.except(:url).each do |key, value|
        unless key == :headers
          Rails.logger.debug "#{key.to_s.ljust(10, ' ')} : #{value}"
          next
        end
      end
    end

    def self.process_headers(str)
      str.split("\r\n")
         .map(&:strip)
         .map { |x| x.split(': ') }
         .map { |k, v| [k.underscore.to_sym, v] }
         .compact
         .to_h
    end

    def self.commit(request)
      hydra = ::Typhoeus::Hydra.hydra
      hydra.queue(request)
      hydra.run
      request.response
    end
  end
end
