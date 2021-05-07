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
    allow(SecureRandom).to receive(:random_bytes)
      .with(16).and_return("r\x01\xD4)-S\xEFx\xFB\x93u{\xB4f\xF5\xAB".b)
  end

  describe '#url' do
    subject { check_in.url }

    it 'returns a correct URL' do
      expect(subject)
        .to eq('https://e.coronawarn.app?v=1#CAESGAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbhqXAQgBEoABZ3dMTXpFMTUzdFF3QU9mMk1ab1VYWGZ6V1RkbFNwZlM5OWlaZmZtY214T0c5bmpTSzRSVGltRk9Gd0RoNnQwVHl3OFhSMDF1Z0RZanR1S3dqanVLNDlPaDgzRldjdDZYcGVmUGk5U2tqeHZ2ejUzaTlnYU1tVUVjOTZwYnRvYUEaEHIB1CktU-94-5N1e7Rm9as=')
    end
  end
end
