# frozen_string_literal: true

require_relative 'validator'
require_relative 'proto/presence_tracing_pb'

require 'base64'
require 'securerandom'

module CoronaPresenceTracing
  module Base
    attr_reader :description, :address, :start_time, :end_time

    def initialize(options = {})
      @description = options[:description]
      @address = options[:address]
      @start_time = options[:start_time]
      @end_time = options[:end_time]

      validate
      build_payload
    end

    def url
      "#{self.class::BASE_URL}##{encoded_payload}"
    end

    private

    def validate
      CheckInValidator.new(self).validate
    end

    def build_payload
      @qr_payload = QRCodePayload.new(
        version: 1,
        locationData: location_data,
        crowdNotifierData: crowd_notifier_data,
        countryData: encoded_vendor_data
      )
    end

    def location_data
      TraceLocation.new(
        version: 1,
        description: description,
        address: address,
        startTimestamp: start_time.to_i,
        endTimestamp: end_time.to_i
      )
    end

    def crowd_notifier_data
      CrowdNotifierData.new(
        version: 1,
        publicKey: self.class::PUBLIC_KEY,
        cryptographicSeed: SecureRandom.random_bytes(16)
      )
    end

    def vendor_data
      nil
    end

    def encoded_vendor_data
      return unless vendor_data

      vendor_data.class.encode(vendor_data)
    end

    def encoded_payload
      Base64.urlsafe_encode64(QRCodePayload.encode(@qr_payload))
    end
  end
end
