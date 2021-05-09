# frozen_string_literal: true

require_relative 'base'
require_relative 'proto/presence_tracing_pb'

module CoronaPresenceTracing
  class CWACheckIn
    include Base

    BASE_URL = 'https://e.coronawarn.app?v=1'
    PUBLIC_KEY = 'gwLMzE153tQwAOf2MZoUXXfzWTdlSpfS99iZffmcmxOG9njSK4RTimFOFwDh6t0T' \
                 'yw8XR01ugDYjtuKwjjuK49Oh83FWct6XpefPi9Skjxvvz53i9gaMmUEc96pbtoaA'

    attr_reader :location_type, :default_check_in_length

    class << self
      private

      def vendor_info(country_data)
        location_data = CWALocationData.decode(country_data)
        {
          location_type: location_type_from_payload(location_data),
          default_check_in_length: location_data.defaultCheckInLengthInMinutes
        }
      end

      def location_type_from_payload(location_data)
        location_data.type.to_s.delete_prefix('LOCATION_TYPE_').downcase.to_sym
      end
    end

    def initialize(options = {})
      @location_type = options[:location_type]
      @default_check_in_length = options[:default_check_in_length]
      super
    end

    private

    def vendor_data
      CWALocationData.new(
        version: 1,
        type: mapped_location_type,
        defaultCheckInLengthInMinutes: default_check_in_length
      )
    end

    def mapped_location_type
      CoronaPresenceTracing::TraceLocationType.const_get("LOCATION_TYPE_#{location_type.to_s.upcase}")
    end
  end
end
