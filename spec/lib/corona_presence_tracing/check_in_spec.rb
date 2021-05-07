# frozen_string_literal: true

RSpec.describe CoronaPresenceTracing::CheckIn do
  let(:check_in) { described_class.new(event_data) }
  let(:event_data) do
    {
      description: 'Fun Activity',
      address: 'Berlin',
      type: 0
    }
  end

  before do
    allow(SecureRandom).to receive(:hex).with(8).and_return('c2c2d106ff49ec1d')
  end

  describe '#url' do
    subject { check_in.url }

    it 'returns a correct URL' do
      expect(subject)
        .to eq('https://e.coronawarn.app?v=1#CAESGAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbhqXAQgBEoABZ' \
               '3dMTXpFMTUzdFF3QU9mMk1ab1VYWGZ6V1RkbFNwZlM5OWlaZmZtY214T0c5bmpTSzRSVGltRk9Gd0R' \
               'oNnQwVHl3OFhSMDF1Z0RZanR1S3dqanVLNDlPaDgzRldjdDZYcGVmUGk5U2tqeHZ2ejUzaTlnYU1tV' \
               'UVjOTZwYnRvYUEaEGMyYzJkMTA2ZmY0OWVjMWQ=')
    end
  end
end
