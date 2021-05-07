# frozen_string_literal: true

require_relative '../../support/shared_examples/check_in'

RSpec.describe CoronaPresenceTracing::CWACheckIn do
  it_behaves_like 'generic check-in'

  describe '#url' do
    subject(:url) { check_in.url }

    let(:check_in) { described_class.new(event_data) }
    let(:event_data) do
      start_time = Time.parse('2021-05-01 18:00')
      {
        description: 'Fun Activity',
        address: 'Berlin',
        start_time: start_time,
        end_time: start_time + 1,
        type: 0,
        default_check_in_length: 42
      }
    end

    include_context 'with static crypto seed'

    it 'returns a correct URL' do
      expect(url)
        .to eq('https://e.coronawarn.app?v=1#CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiA9rWEBjCB9rWEBhqXAQgBEoABZ3dMTXpFMTUzdFF3QU9mMk1ab1VYWGZ6V1RkbFNwZlM5OWlaZmZtY214T0c5bmpTSzRSVGltRk9Gd0RoNnQwVHl3OFhSMDF1Z0RZanR1S3dqanVLNDlPaDgzRldjdDZYcGVmUGk5U2tqeHZ2ejUzaTlnYU1tVUVjOTZwYnRvYUEaEHIB1CktU-94-5N1e7Rm9asiBAgBGCo=')
    end
  end
end
