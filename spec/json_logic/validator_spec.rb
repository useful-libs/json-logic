# frozen_string_literal: true

RSpec.describe JsonLogic::Validator do
  describe '#is_valid?' do
    subject { described_class.new.json_logic_valid?(rules) }

    context 'when valid operator with primitive' do
      let(:rules) { { '==' => [{ 'var' => 'temp' }, 3] } }

      it { is_expected.to be_truthy }
    end

    context 'when valid operator with array' do
      let(:rules) { { 'in' => [{ 'var' => 'temp' }, [3, 4]] } }

      it { is_expected.to be_truthy }
    end

    context 'when valid operator with false' do
      let(:rules) { { 'and' => [{ '==' => [{ 'var' => 'green_card' }, false] }] } }

      it { is_expected.to be_truthy }
    end

    context 'when valid operator with hash' do
      let(:rules) { { '==' => [{ 'var' => 'temp' }, { 'x' => 'y' }] } }

      it { is_expected.to be_falsey }
    end

    context 'when invalid operator' do
      let(:rules) { { '==!!' => [{ 'var' => 'temp' }, 3] } }

      it { is_expected.to be_falsey }
    end

    context 'when a hash without var' do
      let(:rules) { { 'bar' => 'temp' } }

      it { is_expected.to be_falsey }
    end

    context 'when a primitive' do
      let(:rules) { 'test' }

      it { is_expected.to be_truthy }
    end
  end
end
