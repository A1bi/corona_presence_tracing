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
      end_time: start_time + 3600,
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

  describe '.decode' do
    subject(:check_in) { described_class.decode(encoded_payload) }

    let(:encoded_payload) { 'CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiQovmQBjCgvvmQBhp2CAESYIMCzMxNed7UMADn9jGaFF1381k3ZUqX0vfYmX35nJsThvZ40iuEU4phThcA4erdE8sPF0dNboA2I7bisI47iuPTofNxVnLel6Xnz4vUpI8b78-d4vYGjJlBHPeqW7aGgBoQNzIwMWQ0MjkyZDUzZWY3OCIGCAEQAxgt' } # rubocop:disable Layout/LineLength

    it 'returns an instance with correct vendor attributes' do
      expect(check_in.location_type).to eq(:permanent_retail)
      expect(check_in.default_check_in_length).to eq(45)
    end
  end

  describe '#url' do
    subject(:url) { check_in.url }

    include_context 'with static crypto seed'

    context 'with a temporary location' do
      it 'returns a correct URL' do
        expect(url)
          .to eq('https://e.coronawarn.app?v=1#CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiQovmQBjCgvvmQBhp2CAESYIMCzMxNed7UMADn9jGaFF1381k3ZUqX0vfYmX35nJsThvZ40iuEU4phThcA4erdE8sPF0dNboA2I7bisI47iuPTofNxVnLel6Xnz4vUpI8b78-d4vYGjJlBHPeqW7aGgBoQNzIwMWQ0MjkyZDUzZWY3OCIECAEQCQ==')
      end
    end

    context 'with a permanent location' do
      before do
        event_data[:location_type] = :permanent_food_service
        event_data[:default_check_in_length] = 120
      end

      it 'returns a correct URL' do
        expect(url)
          .to eq('https://e.coronawarn.app?v=1#CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiQovmQBjCgvvmQBhp2CAESYIMCzMxNed7UMADn9jGaFF1381k3ZUqX0vfYmX35nJsThvZ40iuEU4phThcA4erdE8sPF0dNboA2I7bisI47iuPTofNxVnLel6Xnz4vUpI8b78-d4vYGjJlBHPeqW7aGgBoQNzIwMWQ0MjkyZDUzZWY3OCIGCAEQBBh4')
      end
    end
  end
end
