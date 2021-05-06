# frozen_string_literal: true

module CoronaPresenceTracing
  class CheckIn
    BASE_URL = 'https://e.coronawarn.app?v=1'

    attr_reader :description, :address, :type, :start_time, :end_time

    def initialize(options = {})
      @description = options[:description]
      @address = options[:address]
      @type = options[:type]
      @start_time = options[:start_time]
      @end_time = options[:end_time]

      @location = TraceLocation.new(version: 1)
      update_location
    end

    def url
      "#{BASE_URL}##{encoded_payload}"
    end

    private

    def update_location
      @location.description = description
      @location.address = address
      @location.startTimestamp = start_time.to_i
      @location.endTimestamp = end_time.to_i
    end

    def encoded_payload
      'foo'
    end
  end
end
