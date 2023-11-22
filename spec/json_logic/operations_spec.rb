# frozen_string_literal: true

require 'date'

RSpec.describe 'JsonLogic::Operations' do
  let(:operations) { JsonLogic::OPERATIONS }

  it 'supports == operation' do
    expect(operations['=='].call(1, 1)).to be_truthy
    expect(operations['=='].call(1, 1.0)).to be_truthy
    expect(operations['=='].call('a', 'a')).to be_truthy
    expect(operations['=='].call(true, true)).to be_truthy
    expect(operations['=='].call(false, false)).to be_truthy
    expect(operations['=='].call(nil, nil)).to be_truthy
    expect(operations['=='].call('', '')).to be_truthy
    expect(operations['=='].call(Date.new(2023, 11, 21), Date.new(2023, 11, 21))).to be_truthy
    # JS gives false for arrays and hashes
    expect(operations['=='].call([], [])).to be_truthy
    expect(operations['=='].call([1], [1])).to be_truthy
    expect(operations['=='].call({}, {})).to be_truthy
    expect(operations['=='].call({ a: 2 }, { a: 2 })).to be_truthy

    expect(operations['=='].call(1, 2)).to be_falsey
    expect(operations['=='].call(1, 'a')).to be_falsey
    expect(operations['=='].call(1, false)).to be_falsey
    expect(operations['=='].call(1, true)).to be_falsey
    expect(operations['=='].call(false, nil)).to be_falsey
    expect(operations['=='].call({ a: 2 }, { a: 3 })).to be_falsey
    expect(operations['=='].call([2], [3])).to be_falsey
    expect(operations['=='].call([], {})).to be_falsey
    expect(operations['=='].call(Date.new(2023, 11, 22), Date.new(2023, 11, 21))).to be_falsey
  end

  it 'supports != operation' do
    expect(operations['!='].call(1, 2)).to be_truthy
    expect(operations['!='].call(false, nil)).to be_truthy
    expect(operations['!='].call(Date.new(2023, 11, 22), Date.new(2023, 11, 21))).to be_truthy

    expect(operations['!='].call(1, 1)).to be_falsey
    expect(operations['!='].call(nil, nil)).to be_falsey
  end

  it 'supports > operation' do
    expect(operations['>'].call(2, 1)).to be_truthy
    expect(operations['>'].call('b', 'a')).to be_truthy
    expect(operations['>'].call(true, false)).to be_truthy
    expect(operations['>'].call(true, nil)).to be_truthy
    expect(operations['>'].call(Date.new(2023, 11, 22), Date.new(2023, 11, 21))).to be_truthy

    expect(operations['>'].call(1, 1)).to be_falsey
    expect(operations['>'].call(1, 2)).to be_falsey
    expect(operations['>'].call('a', 'a')).to be_falsey
    expect(operations['>'].call('a', 'b')).to be_falsey
    expect(operations['>'].call(false, true)).to be_falsey
    expect(operations['>'].call(false, nil)).to be_falsey
  end

  it 'supports >= operation' do
    expect(operations['>='].call(2, 1)).to be_truthy
    expect(operations['>='].call(1, 1)).to be_truthy
    expect(operations['>='].call('a', 'a')).to be_truthy
    expect(operations['>='].call('b', 'a')).to be_truthy
    expect(operations['>='].call(true, false)).to be_truthy
    expect(operations['>='].call(true, nil)).to be_truthy
    expect(operations['>='].call(Date.new(2023, 11, 21), Date.new(2023, 11, 21))).to be_truthy

    expect(operations['>='].call(1, 2)).to be_falsey
    expect(operations['>='].call('a', 'b')).to be_falsey
    expect(operations['>='].call(false, true)).to be_falsey
    expect(operations['>='].call(nil, true)).to be_falsey
    expect(operations['>='].call(Date.new(2023, 11, 21), Date.new(2023, 11, 22))).to be_falsey
  end

  it 'supports < operation' do
    expect(operations['<'].call(1, 2)).to be_truthy
    expect(operations['<'].call('a', 'b')).to be_truthy
    expect(operations['<'].call(false, true)).to be_truthy
    expect(operations['<'].call(nil, true)).to be_truthy
    expect(operations['<'].call(Date.new(2023, 11, 21), Date.new(2023, 11, 22))).to be_truthy

    expect(operations['<'].call(1, 1)).to be_falsey
    expect(operations['<'].call(2, 1)).to be_falsey
  end

  it 'supports <= operation' do
    expect(operations['<='].call(1, 2)).to be_truthy
    expect(operations['<='].call(1, 1)).to be_truthy
    expect(operations['<='].call(Date.new(2023, 11, 21), Date.new(2023, 11, 22))).to be_truthy

    expect(operations['<='].call(2, 1)).to be_falsey

    expect(operations['<='].call(1, 2, 3)).to be_truthy
    expect(operations['<='].call(2, 2, 3)).to be_truthy
    expect(operations['<='].call(2, 2, 2)).to be_truthy
    expect(operations['<='].call(1, 2, 2)).to be_truthy
    expect(operations['<='].call(Date.new(2023, 11, 21), Date.new(2023, 11, 22), Date.new(2023, 11, 23))).to be_truthy

    expect(operations['<='].call(3, 2, 1)).to be_falsey
    expect(operations['<='].call(3, 2, 2)).to be_falsey
    expect(operations['<='].call(2, 2, 1)).to be_falsey
  end

  it 'supports ! operation' do
    expect(operations['!'].call(0)).to be_truthy
    expect(operations['!'].call(false)).to be_truthy
    expect(operations['!'].call('')).to be_truthy
    expect(operations['!'].call(nil)).to be_truthy
    expect(operations['!'].call([])).to be_truthy
    expect(operations['!'].call({})).to be_truthy

    expect(operations['!'].call(1)).to be_falsey
    expect(operations['!'].call('a')).to be_falsey
    expect(operations['!'].call('0')).to be_falsey
    expect(operations['!'].call([1])).to be_falsey
    expect(operations['!'].call(true)).to be_falsey
    expect(operations['!'].call(Date.new(2023, 11, 21))).to be_falsey
  end

  it 'supports !! operation' do
    expect(operations['!!'].call(1)).to be_truthy
    expect(operations['!!'].call('a')).to be_truthy
    expect(operations['!!'].call([1])).to be_truthy
    expect(operations['!!'].call(true)).to be_truthy
    expect(operations['!!'].call(Date.new(2023, 11, 21))).to be_truthy

    expect(operations['!!'].call(0)).to be_falsey
    expect(operations['!!'].call(false)).to be_falsey
    expect(operations['!!'].call('')).to be_falsey
    expect(operations['!!'].call(nil)).to be_falsey
    expect(operations['!!'].call([])).to be_falsey
    expect(operations['!!'].call({})).to be_falsey
  end

  it 'supports % operation' do
    expect(operations['%'].call(7, 4)).to eq(3)
  end

  it 'supports and operation' do
    expect(operations['and'].call(true, true)).to be(true)
    expect(operations['and'].call(1, 2)).to eq(2)
    expect(operations['and'].call('a', 'b')).to eq('b')
    expect(operations['and'].call(true, false)).to be(false)
    expect(operations['and'].call(true, nil)).to be_nil
  end

  it 'supports or operation' do
    expect(operations['or'].call(true, true)).to be(true)
    expect(operations['or'].call(1, 2)).to eq(1)
    expect(operations['or'].call('a', 'b')).to eq('a')
    expect(operations['or'].call(true, false)).to be(true)
    expect(operations['or'].call(true, nil)).to be(true)
    expect(operations['or'].call(false, nil)).to be_nil
  end

  it 'supports ?: operation' do
    expect(operations['?:'].call(true, 1, 2)).to eq(1)
    expect(operations['?:'].call('a', 1, 2)).to eq(1)
    expect(operations['?:'].call('0', 1, 2)).to eq(1)

    expect(operations['?:'].call(false, 1, 2)).to eq(2)
    expect(operations['?:'].call(nil, 1, 2)).to eq(2)
    expect(operations['?:'].call(0, 1, 2)).to eq(2)
    expect(operations['?:'].call([], 1, 2)).to eq(2)
    expect(operations['?:'].call({}, 1, 2)).to eq(2)
    expect(operations['?:'].call('', 1, 2)).to eq(2)
  end

  it 'supports if operation' do
    expect(operations['if'].call(true, 1, 2)).to eq(1)
    expect(operations['if'].call(false, 1, 2)).to eq(2)
    expect(operations['if'].call(nil, 1, 2)).to eq(2)

    expect(operations['if'].call(1, 1, 2)).to eq(1)
    expect(operations['if'].call('a', 1, 2)).to eq(1)
    expect(operations['if'].call([1], 1, 2)).to eq(1)
    expect(operations['if'].call({ a: 3 }, 1, 2)).to eq(1)

    expect(operations['if'].call('', 1, 2)).to eq(2)
    expect(operations['if'].call([], 1, 2)).to eq(2)
    expect(operations['if'].call(0, 1, 2)).to eq(2)

    expect(operations['if'].call(true, 1)).to eq(1)
    expect(operations['if'].call(false, 1)).to be_nil
  end

  it 'supports log operation' do
    expect { operations['log'].call(1) }.to output("1\n").to_stdout
    expect { operations['log'].call('1') }.to output("1\n").to_stdout
    expect { operations['log'].call(true) }.to output("true\n").to_stdout
  end

  it 'supports in operation' do
    expect(operations['in'].call(1, [2, 1])).to be_truthy
    expect(operations['in'].call(true, [false, true])).to be_truthy
    expect(operations['in'].call(nil, [false, nil])).to be_truthy
    expect(operations['in'].call('a', 'ab')).to be_truthy
    expect(operations['in'].call(:a, { a: 3 })).to be_truthy

    expect(operations['in'].call(1, [2, 3])).to be_falsey
    expect(operations['in'].call(nil, [false, true])).to be_falsey
    expect(operations['in'].call(1, 1)).to be_falsey
    expect(operations['in'].call('a', 'bc')).to be_falsey
    expect(operations['in'].call(3, { a: 3 })).to be_falsey
  end

  it 'supports cat operation' do
    expect(operations['cat'].call(1)).to eq('1')
    expect(operations['cat'].call(1, 2)).to eq('12')
    expect(operations['cat'].call('a', 'b')).to eq('ab')
    expect(operations['cat'].call(true, false)).to eq('truefalse')
    expect(operations['cat'].call(true, nil)).to eq('true')
  end

  it 'supports + operation' do
    expect(operations['+'].call(1)).to eq(1)
    expect(operations['+'].call(1, 2)).to eq(3)
  end

  it 'supports * operation' do
    expect(operations['*'].call(1)).to eq(1)
    expect(operations['*'].call(2, 3)).to eq(6)
  end

  it 'supports - operation' do
    expect(operations['-'].call(1)).to eq(-1)
    expect(operations['-'].call(5, 3)).to eq(2)
  end

  it 'supports / operation' do
    expect(operations['/'].call(1, 2)).to eq(0.5)
    expect(operations['/'].call(6, 3)).to eq(2)
  end

  it 'supports min operation' do
    expect(operations['min'].call(1)).to eq(1)
    expect(operations['min'].call(1, 2)).to eq(1)
    expect(operations['min'].call(true, true)).to eq(1)
    expect(operations['min'].call(false, true)).to eq(0)
    expect(operations['min'].call(nil, false)).to eq(0)
    expect(operations['min'].call(Date.new(2023, 11, 21), Date.new(2023, 11, 22))).to eq(Date.new(2023, 11, 21))
  end

  it 'supports max operation' do
    expect(operations['max'].call(1)).to eq(1)
    expect(operations['max'].call(1, 2)).to eq(2)
    expect(operations['max'].call(false, true)).to eq(1)
    expect(operations['max'].call(nil, false)).to eq(0)
    expect(operations['max'].call(Date.new(2023, 11, 21), Date.new(2023, 11, 22))).to eq(Date.new(2023, 11, 22))
  end

  it 'supports merge operation' do
    expect(operations['merge'].call(1)).to eq([1])
    expect(operations['merge'].call(1, 2)).to eq([1, 2])
    expect(operations['merge'].call(1, 2, [3, 4])).to eq([1, 2, 3, 4])
  end

  it 'supports count operation' do
    expect(operations['count'].call(1, 5)).to eq(2)
    expect(operations['count'].call([1, 5])).to eq(1)
    expect(operations['count'].call).to eq(0)
    expect(operations['count'].call('abcd')).to eq(1)
  end
end
