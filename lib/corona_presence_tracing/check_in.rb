# frozen_string_literal: true

module CoronaPresenceTracing
  class CheckIn
    BASE_URL = 'https://e.coronawarn.app?v=1'

    attr_accessor :description, :address, :type, :start_time, :end_time

    def initialize(options = {})
      @description = options[:description]
      @address = options[:address]
      @type = options[:type]
      @start_time = options[:start_time]
      @end_time = options[:end_time]
    end

    def url
      "#{BASE_URL}##{encoded_payload}"
    end

    private

    def encoded_payload
      'foo'
    end
  end
end
