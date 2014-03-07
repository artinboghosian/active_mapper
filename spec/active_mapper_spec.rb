require 'spec_helper'

describe ActiveMapper do
  describe '.[]' do
    it 'returns the stored mapper' do
      expect(ActiveMapper[User].mapped_class).to eql(User)
    end
  end

  describe '.adapter' do
    let(:adapter) { double('Adapter') }

    it 'returns the adapter that has been set' do
      ActiveMapper.adapter = adapter

      expect(ActiveMapper.adapter).to eq(adapter)
    end

    it 'defaults to the memory store' do
      ActiveMapper.adapter = nil

      expect(ActiveMapper.adapter).to be_a(ActiveMapper::Adapter::Memory)
    end
  end
end