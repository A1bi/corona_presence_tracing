# frozen_string_literal: true

require_relative 'base'
require_relative 'proto/presence_tracing_pb'

module CoronaPresenceTracing
  class CWACheckIn
    include Base

    BASE_URL = 'https://e.coronawarn.app?v=1'
    PUBLIC_KEY = 'gwLMzE153tQwAOf2MZoUXXfzWTdlSpfS99iZffmcmxOG9njSK4RTimFOFwDh6t0T' \
                 'yw8XR01ugDYjtuKwjjuK49Oh83FWct6XpefPi9Skjxvvz53i9gaMmUEc96pbtoaA'

    attr_reader :type, :default_check_in_length

    def initialize(options = {})
      @type = options[:type]
      @default_check_in_length = options[:default_check_in_length]
      super
    end

    private

    def vendor_data
      CWALocationData.new(
        version: 1,
        type: type,
        defaultCheckInLengthInMinutes: default_check_in_length
      )
    end
  end
end
