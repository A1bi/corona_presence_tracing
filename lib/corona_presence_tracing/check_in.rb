# frozen_string_literal: true

require 'base64'
require 'securerandom'

module CoronaPresenceTracing
  class CheckIn
    BASE_URL = 'https://e.coronawarn.app?v=1'
    PUBLIC_KEY = 'gwLMzE153tQwAOf2MZoUXXfzWTdlSpfS99iZffmcmxOG9njSK4RTimFOFwDh6t0T' \
                 'yw8XR01ugDYjtuKwjjuK49Oh83FWct6XpefPi9Skjxvvz53i9gaMmUEc96pbtoaA'

    attr_reader :description, :address, :type, :start_time, :end_time

    def initialize(options = {})
      @description = options[:description]
      @address = options[:address]
      @type = options[:type]
      @start_time = options[:start_time]
      @end_time = options[:end_time]

      build_payload
    end

    def url
      "#{BASE_URL}##{encoded_payload}"
    end

    private

    def build_payload
      build_location
      build_crowd_notifier_data
      build_qr_payload
    end

    def build_location
      @location = TraceLocation.new(version: 1)
      @location.description = description
      @location.address = address
      @location.startTimestamp = start_time.to_i
      @location.endTimestamp = end_time.to_i
    end

    def build_crowd_notifier_data
      @crowd_notifier_data = CrowdNotifierData.new(
        version: 1,
        publicKey: PUBLIC_KEY,
        cryptographicSeed: SecureRandom.random_bytes(16)
      )
    end

    def build_qr_payload
      @qr_payload = QRCodePayload.new(
        version: 1,
        locationData: @location,
        crowdNotifierData: @crowd_notifier_data
      )
    end

    def encoded_payload
      Base64.urlsafe_encode64(QRCodePayload.encode(@qr_payload))
    end
  end
end
