# frozen_string_literal: true

require_relative 'validator'
require_relative 'proto/presence_tracing_pb'

require 'base64'
require 'securerandom'

module CoronaPresenceTracing
  module Base
    attr_reader :description, :address, :start_time, :end_time

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def decode(encoded_payload)
        base64_segment = encoded_payload.split('#').last
        qr_payload = QRCodePayload.decode(Base64.urlsafe_decode64(base64_segment))
        location = qr_payload.locationData

        new(
          description: location.description,
          address: location.address,
          start_time: Time.at(location.startTimestamp),
          end_time: Time.at(location.endTimestamp),
          **vendor_info(qr_payload.vendorData)
        )
      end

      private

      def vendor_info(_country_data)
        {}
      end
    end

    def initialize(options = {})
      @description = options[:description]
      @address = options[:address]
      @start_time = options[:start_time]
      @end_time = options[:end_time]

      validate
      build_payload
    end

    def encoded_payload
      @encoded_payload ||= Base64.urlsafe_encode64(QRCodePayload.encode(@qr_payload))
    end

    def url
      [self.class::BASE_URL, encoded_payload].join('#')
    end

    private

    def validate
      CoronaPresenceTracing.const_get("#{self.class.name}Validator").new(self).validate
    end

    def build_payload
      @qr_payload = QRCodePayload.new(
        version: 1,
        locationData: location_data,
        crowdNotifierData: crowd_notifier_data,
        vendorData: encoded_vendor_data
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
        publicKey: Base64.decode64(self.class::PUBLIC_KEY),
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
  end
end
