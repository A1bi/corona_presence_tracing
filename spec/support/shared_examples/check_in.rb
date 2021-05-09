# frozen_string_literal: true

RSpec.shared_examples 'raising a validation error' do |attr, error_name|
  it 'raises an error for a blank attribute' do
    expect { subject }
      .to raise_error(CoronaPresenceTracing::ValidationError) do |error|
        expect(error.attr).to eq(attr)
        expect(error.error).to eq(error_name)
      end
  end
end

RSpec.shared_examples 'generic check-in' do
  describe 'validations' do
    subject { described_class.new(event_data) }

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

  describe '.decode' do
    subject(:check_in) { described_class.decode(encoded_payload) }

    let(:encoded_payload) { 'CAESJAgBEgxGdW4gQWN0aXZpdHkaBkJlcmxpbiiQovmQBjCgvvmQBhp2CAESYIMCzMxNed7UMADn9jGaFF1381k3ZUqX0vfYmX35nJsThvZ40iuEU4phThcA4erdE8sPF0dNboA2I7bisI47iuPTofNxVnLel6Xnz4vUpI8b78-d4vYGjJlBHPeqW7aGgBoQNzIwMWQ0MjkyZDUzZWY3OCIECAEQCQ==' } # rubocop:disable Layout/LineLength

    shared_examples 'generic payload decoder' do
      it 'returns an instance with correct attributes' do
        expect(check_in.description).to eq('Fun Activity')
        expect(check_in.address).to eq('Berlin')

        start_time = Time.parse('2022-03-01 18:00')
        expect(check_in.start_time).to eq(start_time)
        expect(check_in.end_time).to eq(start_time + 3600)
      end
    end

    context 'with only the payload' do
      it_behaves_like 'generic payload decoder'
    end

    context 'with a full url' do
      let(:encoded_payload) { "https://example.com/foo##{super()}" }

      it_behaves_like 'generic payload decoder'
    end
  end

  describe '#encoded_payload' do
    subject { check_in.encoded_payload }

    let(:check_in) { described_class.new(event_data) }

    it 'returns identical output for consecutive method calls' do
      expect(subject).to eq(check_in.encoded_payload)
    end
  end

  describe '#url' do
    subject { check_in.url }

    let(:check_in) { described_class.new(event_data) }

    it 'returns identical output for consecutive method calls' do
      expect(subject).to eq(check_in.url)
    end
  end
end

RSpec.shared_context 'with static crypto seed' do
  before do
    allow(SecureRandom).to receive(:random_bytes).with(16).and_return('7201d4292d53ef78')
  end
end
