# frozen_string_literal: true

RSpec.describe JsonLogic::Evaluator do
  describe '#apply' do
    subject(:evaluator) { described_class.new.apply(rules, data) }

    context 'with var' do
      let(:rules) { { 'var' => var } }
      let(:data) { { 'a' => 1, 'b' => 2 } }

      context 'when data has var and var is not array' do
        let(:var) { 'a' }

        it { is_expected.to eq(1) }
      end

      context 'when data has var and var is array' do
        let(:var) { ['a'] }

        it { is_expected.to eq(1) }
      end

      context 'when var is nested' do
        let(:var) { ['a.b'] }
        let(:data) { { 'a' => { 'b' => 3 } } }

        it { is_expected.to eq(3) }
      end

      context 'when data does not has var' do
        let(:var) { 'z' }

        it { is_expected.to be_nil }
      end

      context 'when data does not has var but default value is provided' do
        let(:var) { ['z', 26] }

        it { is_expected.to eq(26) }
      end

      context 'when access to array' do
        let(:var) { 1 }
        let(:data) { %w[zero one two] }

        it { is_expected.to eq('one') }
      end

      context 'when var is empty' do
        let(:var) { '' }

        it { is_expected.to eq(data) }
      end

      context 'when access dates' do
        let(:data) { { 'a' => Date.new(2023, 11, 21) } }
        let(:var) { 'a' }

        it { is_expected.to eq(Date.new(2023, 11, 21)) }
      end
    end

    context 'with missing' do
      let(:rules) { { 'missing' => missing } }
      let(:data) { { 'a' => 1, 'b' => 2 } }

      context 'when one key missed' do
        let(:missing) { %w[a c] }

        it { is_expected.to eq(['c']) }
      end

      context 'when two keys missed' do
        let(:missing) { %w[a c d] }

        it { is_expected.to eq(%w[c d]) }
      end

      context 'when all keys present' do
        let(:missing) { %w[a b] }

        it { is_expected.to be_empty }
      end
    end

    context 'with missing_some' do
      let(:rules) { { 'missing_some' => missing_some } }
      let(:data) { { 'a' => 1, 'b' => 2 } }
      let(:missing_some) { [required_count, %w[a b c d]] }

      context 'when required count of keys (1) is present' do
        let(:required_count) { 1 }

        it { is_expected.to be_empty }
      end

      context 'when required count of keys (>1) is present' do
        let(:required_count) { 2 }

        it { is_expected.to be_empty }
      end

      context 'when required count of keys is not present' do
        let(:required_count) { 3 }

        it { is_expected.to eq(%w[c d]) }
      end
    end

    context 'with operation' do
      context 'when data present' do
        let(:rules) do
          { 'if' => [
            { '<' => [{ 'var' => 'temp' }, 0] }, 'freezing',
            { '<' => [{ 'var' => 'temp' }, 100] }, 'liquid', 'gas'
          ] }
        end
        let(:data) { { 'temp' => 55 } }

        it { is_expected.to eq('liquid') }
      end

      context 'when data missed' do
        let(:rules) { { 'if' => [true, 'yes', 'no'] } }
        let(:data) { {} }

        it { is_expected.to eq('yes') }
      end
    end

    context 'when map' do
      let(:rules) do
        {
          'map' => [
            { 'var' => 'list' },
            {
              'if' => [
                { '==' => [{ '%' => [{ 'var' => '' }, 15] }, 0] }, 'fizzbuzz',
                { '==' => [{ '%' => [{ 'var' => '' }, 3] }, 0] }, 'fizz',
                { '==' => [{ '%' => [{ 'var' => '' }, 5] }, 0] }, 'buzz',
                { 'var' => '' }
              ]
            }
          ]
        }
      end
      let(:data) { { 'list' => [*1..30] } }
      let(:result) do
        [1, 2, 'fizz', 4, 'buzz', 'fizz', 7, 8, 'fizz', 'buzz', 11, 'fizz', 13, 14, 'fizzbuzz',
         16, 17, 'fizz', 19, 'buzz', 'fizz', 22, 23, 'fizz', 'buzz', 26, 'fizz', 28, 29, 'fizzbuzz']
      end

      it { is_expected.to eq(result) }
    end

    context 'when !' do
      context 'when not between' do
        let(:rules) { { '!' => { '<=' => [70, { 'var' => 'age' }, 75] } } }

        context 'when main part is false' do
          let(:data) { { 'age' => 69 } }

          it { is_expected.to be(true) }
        end

        context 'when main part is true' do
          let(:data) { { 'age' => 72 } }

          it { is_expected.to be(false) }
        end
      end

      context 'when not one of (select not any in)' do
        context 'with string' do
          let(:rules) { { '!' => { 'in' => [{ 'var' => 'drink' }, 'sell cola'] } } }

          context 'when main part is false' do
            let(:data) { { 'drink' => 'beer' } }

            it { is_expected.to be(true) }
          end

          context 'when main part is true' do
            let(:data) { { 'drink' => 'cola' } }

            it { is_expected.to be(false) }
          end
        end

        context 'with array' do
          let(:rules) { { '!' => { 'in' => [{ 'var' => 'drink' }, %w[cola juice]] } } }

          context 'when main part is false' do
            let(:data) { { 'drink' => 'beer' } }

            it { is_expected.to be(true) }
          end

          context 'when main part is true' do
            let(:data) { { 'drink' => 'cola' } }

            it { is_expected.to be(false) }
          end
        end
      end

      context 'when does not contain any of (not like)' do
        context 'with string' do
          let(:rules) { { '!' => { 'in' => ['ol', { 'var' => 'drink' }] } } }

          context 'when main part is false' do
            let(:data) { { 'drink' => 'juice' } }

            it { is_expected.to be(true) }
          end

          context 'when main part is true' do
            let(:data) { { 'drink' => 'cola' } }

            it { is_expected.to be(false) }
          end
        end

        context 'with array' do
          let(:rules) { { '!' => { 'in' => ['beer', { 'var' => 'drinks' }] } } }

          context 'when main part is false' do
            let(:data) { { 'drinks' => %w[cola juice] } }

            it { is_expected.to be(true) }
          end

          context 'when main part is true' do
            let(:data) { { 'drinks' => %w[beer cola] } }

            it { is_expected.to be(false) }
          end
        end
      end
    end
  end

  describe '#get_var_name' do
    subject(:get_var_name) { described_class.new.send(:get_var_name, operator, rule) }

    context 'when two args' do
      let(:operator) { '==' }
      let(:rule) { { '==' => [{ 'var' => 'a' }, 11] } }

      it { is_expected.to eq('a') }
    end

    context 'when three args' do
      let(:operator) { '<=' }
      let(:rule) { { '<=' => [5, { 'var' => 'a' }, 11] } }

      it { is_expected.to eq('a') }
    end
  end

  describe '#get_var_value' do
    subject(:get_var_value) { described_class.new.send(:get_var_value, *args) }

    let(:args) { [data, var_name] }

    context 'when data is hash' do
      let(:data) { { 'a' => 1, 'b' => 2 } }

      context 'when value present' do
        let(:var_name) { 'a' }

        it { is_expected.to eq(1) }
      end

      context 'when value missed' do
        let(:var_name) { 'z' }

        it { is_expected.to be_nil }
      end

      context 'when value is true' do
        let(:data) { { 'a' => true } }
        let(:var_name) { 'a' }

        it { is_expected.to be(true) }
      end

      context 'when value is false' do
        let(:data) { { 'a' => false } }
        let(:var_name) { 'a' }

        it { is_expected.to be(false) }
      end
    end

    context 'when data is array' do
      let(:data) { [11, 22, 33] }

      context 'when value present' do
        let(:var_name) { 1 }

        it { is_expected.to eq(22) }
      end

      context 'when value missed' do
        let(:var_name) { 4 }

        it { is_expected.to be_nil }
      end
    end

    context 'when data is not Array or Hash' do
      let(:data) { 11 }

      context 'when var_name is nil' do
        let(:var_name) { nil }

        it { is_expected.to eq(data) }
      end

      context 'when var_name is not nil' do
        let(:var_name) { '' }

        it { is_expected.to eq(data) }
      end
    end

    context 'when default value present' do
      let(:args) { [data, var_name, default_value] }
      let(:data) { { 'a' => 1, 'b' => 2 } }
      let(:default_value) { 77 }

      context 'when value present' do
        let(:var_name) { 'a' }

        it { is_expected.to eq(1) }
      end

      context 'when value missed' do
        let(:var_name) { 'z' }

        it { is_expected.to eq(default_value) }
      end
    end

    context 'when value is nested' do
      let(:data) { { 'a' => { 'b' => { 'c' => 11, 'd' => 5 }, 'e' => 6 }, 'f' => 7 } }
      let(:var_name) { 'a.b.c' }

      it { is_expected.to eq(11) }
    end
  end

  describe '#extract_vars' do
    subject { described_class.new.send(:extract_vars, rules) }

    context 'with correct rules' do
      context 'when rules is Hash' do
        let(:rules) { { '>' => [{ 'var' => 'felony_count' }, 5] } }

        it { is_expected.to eq(['felony_count']) }
      end

      context 'when rules is Array' do
        let(:rules) do
          [
            { '>' => [{ 'var' => 'felony_count' }, 5] },
            { 'in' => [{ 'var' => 'severe_felony' }, %w[Murder Manslaughter]] }
          ]
        end

        it { is_expected.to eq(%w[felony_count severe_felony]) }
      end
    end

    context 'with incorrect rules' do
      context 'when rules is Hash' do
        let(:rules) { { '>' => [{ 'bar' => 'felony_count' }, 5] } }

        it { is_expected.to be_empty }
      end

      context 'when rules is Array' do
        let(:rules) do
          [
            { '>' => [{ 'baz' => 'felony_count' }, 5] },
            { 'in' => [{ 'tar' => 'severe_felony' }, %w[Murder Manslaughter]] }
          ]
        end

        it { is_expected.to be_empty }
      end
    end
  end

  describe '#fetch_var_values' do
    subject { described_class.new.send(:fetch_var_values, rules, var_name) }

    context 'when variable present' do
      let(:rules) do
        [
          { '>' => [{ 'var' => 'felony_count' }, 5] },
          { 'in' => [{ 'var' => 'severe_felony' }, %w[Murder Manslaughter]] }
        ]
      end
      let(:var_name) { 'felony_count' }

      it { is_expected.to eq([5]) }
    end

    context 'when variable encount several times' do
      let(:rules) do
        [
          { '>' => [{ 'var' => 'felony_count' }, 5] },
          { '<' => [{ 'var' => 'felony_count' }, 10] }
        ]
      end
      let(:var_name) { 'felony_count' }

      it { is_expected.to eq([5, 10]) }
    end

    context 'when variable missed' do
      let(:rules) do
        [
          { '>' => [{ 'var' => 'felony_count' }, 5] },
          { 'in' => [{ 'var' => 'severe_felony' }, %w[Murder Manslaughter]] }
        ]
      end
      let(:var_name) { 'gender' }

      it { is_expected.to be_empty }
    end
  end
end
