require 'spec_helper'

describe ActiveMapper do
  let(:adapter) { double('Adapter') }

  describe '.generate' do
    let(:mapper) { ActiveMapper.generate(User) }

    before { ActiveMapper.adapter = adapter }

    it 'generates a mapper for the specified class' do
      expect(mapper.mapped_class).to eq(User)
    end

    it 'sets the adapter on the generated mapper' do
      expect(mapper.adapter).to eq(adapter)
    end

    it 'stores the generated mapper' do
      expect(ActiveMapper[User]).to eq(mapper)
    end
  end

  describe '.adapter' do
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