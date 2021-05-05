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

  describe '#url' do
    subject { check_in.url }

    it 'returns a correct URL' do
      expect(subject).to include('https://e.coronawarn.app?v=1#foo')
    end
  end
end
