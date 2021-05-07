# frozen_string_literal: true

require_relative '../../support/shared_examples/check_in'

RSpec.describe CoronaPresenceTracing::CWACheckIn do
  let(:check_in) { described_class.new(event_data) }
  let(:event_data) do
    start_time = Time.parse('2022-03-01 18:00')
    {
      description: 'Fun Activity',
      address: 'Berlin',
      start_time: start_time,
      end_time: start_time + 15,
      location_type: :temporary_cultural_event
    }
  end

  it_behaves_like 'generic check-in'

  describe 'validations' do
    subject { described_class.new(event_data) }

    context 'with default_check_in_length too high' do
      before { event_data[:default_check_in_length] = 2000 }

      include_examples 'raising a validation error', :default_check_in_length, :invalid
    end

    context 'with an invalid location type' do
      before { event_data[:location_type] = :foo }

      include_examples 'raising a validation error', :location_type, :invalid
    end

    context 'with a temporary event and a missing start time' do
      before do
        event_data[:location_type] = :temporary_other
        event_data.delete(:start_time)
      end

      include_examples 'raising a validation error', :start_time, :blank
    end

    context 'with a permanent event and a missing default_check_in_length' do
      before do
        event_data[:location_type] = :permanent_other
        event_data.delete(:default_check_in_length)
      end

      include_examples 'raising a validation error', :default_check_in_length, :blank
    end
  end

  describe '#url' do
    subject(:url) { check_in.url }

    include_context 'with static crypto seed'

    it 'returns a correct URL' do
      expect(url)
        .to eq('https://e.coronawarn.app?v=1#CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiQovmQBjCfovmQBhqXAQgBEoABZ3dMTXpFMTUzdFF3QU9mMk1ab1VYWGZ6V1RkbFNwZlM5OWlaZmZtY214T0c5bmpTSzRSVGltRk9Gd0RoNnQwVHl3OFhSMDF1Z0RZanR1S3dqanVLNDlPaDgzRldjdDZYcGVmUGk5U2tqeHZ2ejUzaTlnYU1tVUVjOTZwYnRvYUEaEHIB1CktU-94-5N1e7Rm9asiBAgBEAk=')
    end
  end
end
