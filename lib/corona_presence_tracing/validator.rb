# frozen_string_literal: true

module CoronaPresenceTracing
  class ValidationError < StandardError
    attr_reader :check_in, :attr, :error

    def initialize(check_in, attr, error, message)
      @check_in = check_in
      @attr = attr
      @error = error
      super(message)
    end
  end

  class CheckInValidator
    def initialize(check_in)
      @check_in = check_in
    end

    def validate
      validate_presence_of :description, :address
      validate_type_of :description, :address, [String]
      validate_length_of :description, :address, max: 100
      validate_type_of :start_time, :end_time, [DateTime, Time, Date]
      validate_dates
    end

    private

    def validate_presence_of(*attrs)
      validate_attrs(attrs) do |attr, value|
        raise_error(attr, :blank, "can't be blank") if value.nil? || value.is_a?(String) && value.empty?
      end
    end

    def validate_length_of(*attrs, options)
      max = options[:max]
      validate_attrs(attrs) do |attr, value|
        raise_error(attr, :length, "is too long (max #{max} characters)") if value.size > max
      end
    end

    def validate_type_of(*attrs, types)
      validate_attrs(attrs) do |attr, value|
        raise_error(attr, :type, "must be a #{types.join(' or ')}") unless value.nil? || types.include?(value.class)
      end
    end

    def validate_inclusion_of(*attrs, values)
      validate_attrs(attrs) do |attr, value|
        unless value.nil? || values.include?(value)
          raise_error(attr, :invalid, "must be one of the following values: #{values}")
        end
      end
    end

    def validate_dates
      min = Time.parse('1970-01-01')
      validate_attrs(%i[start_time end_time]) do |attr, value|
        raise_error(attr, :invalid, "must be after #{min}") if value && value < min
      end

      return unless @check_in.end_time && @check_in.start_time && @check_in.end_time < @check_in.start_time

      raise_error(:end_time, :invalid, "can't be before start_time")
    end

    def validate_attrs(attrs)
      attrs.each do |attr|
        yield attr, @check_in.public_send(attr)
      end
    end

    def raise_error(attr, error, message)
      raise ValidationError.new(@check_in, attr, error, "#{attr} #{message}")
    end
  end

  class CWACheckInValidator < CheckInValidator
    ALLOWED_LOCATION_TYPES = %i[
      permanent_retail permanent_food_service permanent_craft permanent_workplace
      permanent_educational_institution permanent_public_building permanent_other
      temporary_cultural_event temporary_club_activity temporary_private_event
      temporary_worship_service temporary_other
    ].freeze

    def validate
      validate_type_of :location_type, [Symbol, String]
      validate_inclusion_of :location_type, ALLOWED_LOCATION_TYPES
      validate_presence_of :default_check_in_length unless temporary_location?
      validate_type_of :default_check_in_length, [Integer]
      validate_inclusion_of :default_check_in_length, (0..1440)
      super
    end

    def validate_dates
      validate_presence_of :start_time, :end_time if temporary_location?
      super
    end

    def temporary_location?
      @check_in.location_type.to_s.start_with?('temporary')
    end
  end
end
