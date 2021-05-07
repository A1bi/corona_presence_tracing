# frozen_string_literal: true

RSpec.describe CoronaPresenceTracing::CheckIn do
  let(:event_data) do
    start_time = Time.parse('2021-05-01 18:00')
    {
      description: 'Fun Activity',
      address: 'Berlin',
      start_time: start_time,
      end_time: start_time + 1
    }
  end

  describe 'validations' do
    subject { described_class.new(event_data) }

    shared_examples 'raising a validation error' do |attr, error_name|
      it 'raises an error for a blank attribute' do
        expect { subject }
          .to raise_error(CoronaPresenceTracing::ValidationError) do |error|
            expect(error.attr).to eq(attr)
            expect(error.error).to eq(error_name)
          end
      end
    end

    context 'with an empty description' do
      before { event_data[:description] = nil }

      include_examples 'raising a validation error', :description, :blank
    end

    context 'with an address too long' do
      before { event_data[:address] = 'f' * 101 }

      include_examples 'raising a validation error', :address, :length
    end

    context 'with an invalid start time' do
      before { event_data[:start_time] = '2014' }

      include_examples 'raising a validation error', :start_time, :type
    end

    context 'with a date before 1970' do
      before { event_data[:start_time] = Time.parse('1969-12-31') }

      include_examples 'raising a validation error', :start_time, :invalid
    end

    context 'with end time earlier than start time' do
      before { event_data[:end_time] = event_data[:start_time] - 1 }

      include_examples 'raising a validation error', :end_time, :invalid
    end
  end

  describe '#url' do
    subject { check_in.url }

    let(:check_in) { described_class.new(event_data) }

    before do
      allow(SecureRandom).to receive(:random_bytes)
        .with(16).and_return("r\x01\xD4)-S\xEFx\xFB\x93u{\xB4f\xF5\xAB".b)
    end

    it 'returns a correct URL' do
      expect(subject)
        .to eq('https://e.coronawarn.app?v=1#CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiA9rWEBjCB9rWEBhqXAQgBEoABZ3dMTXpFMTUzdFF3QU9mMk1ab1VYWGZ6V1RkbFNwZlM5OWlaZmZtY214T0c5bmpTSzRSVGltRk9Gd0RoNnQwVHl3OFhSMDF1Z0RZanR1S3dqanVLNDlPaDgzRldjdDZYcGVmUGk5U2tqeHZ2ejUzaTlnYU1tVUVjOTZwYnRvYUEaEHIB1CktU-94-5N1e7Rm9as=')
    end
  end
end
