require 'spec_helper'

describe ActiveMapper::Relation do
  let(:adapter) { double('Adapter') }
  let(:user) { User.new }
  let(:query) { proc { |user| user.age > 18 } }
  let(:relation) { ActiveMapper::Relation.new(User, adapter, &query) }

  before { adapter.stub(unserialize: user) }

  describe '#all' do
    it 'finds all matching objects' do
      expect(adapter).to receive(:where).with(User, an_instance_of(Hash)) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      expect(relation.all).to eq([user])
    end
  end

  describe '#first' do
    it 'finds the first matching object' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 0, limit: 1)) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      expect(relation.first).to eq(user)
    end
  end

  describe '#last' do
    it 'finds the last matching object' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 0, limit: 1, order: [:id, :desc])) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      expect(relation.last).to eq(user)
    end
  end

  describe '#count' do
    it 'counts the number of matching objects' do
      expect(adapter).to receive(:count).with(User) do |&block|
        expect(block).to eq(query)
      end.and_return(10)

      expect(relation.count).to eq(10)
    end
  end

  describe '#any?' do
    it 'is true when there are matching objects' do
      expect(adapter).to receive(:count).with(User).and_return(1)
      expect(relation.any?).to be_true
    end

    it 'is false when there are no matching objects' do
      expect(adapter).to receive(:count).with(User).and_return(0)
      expect(relation.any?).to be_false
    end
  end

  describe '#none?' do
    it 'is true when there are no matching objects' do
      expect(adapter).to receive(:count).with(User).and_return(0)
      expect(relation.none?).to be_true
    end

    it 'is false when there are matching objects' do
      expect(adapter).to receive(:count).with(User).and_return(1)
      expect(relation.none?).to be_false
    end
  end

  describe '#one?' do
    it 'is true when there is one matching object' do
      expect(adapter).to receive(:count).with(User).and_return(1)
      expect(relation.one?).to be_true
    end

    it 'is false when there are no matching objects' do
      expect(adapter).to receive(:count).with(User).and_return(0)
      expect(relation.one?).to be_false
    end

    it 'is false when there are is more than one matching object' do
      expect(adapter).to receive(:count).with(User).and_return(2)
      expect(relation.one?).to be_false
    end
  end

  describe '#page' do
    it 'sets the page number' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 40)) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      relation.per_page(10).page(5).all
    end
  end

  describe '#per_page' do
    it 'sets the limit' do
      expect(adapter).to receive(:where).with(User, hash_including(limit: 20)) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      relation.per_page(20).all
    end
  end

  describe '#order_by' do
    it 'sets the attribute to order by' do
      expect(adapter).to receive(:where).with(User, hash_including(order: [:name, :asc])) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      relation.sort_by(:name).all
    end
  end

  describe '#reverse' do
    it 'sets the opposite direction to order by' do
      expect(adapter).to receive(:where).with(User, hash_including(order: [:name, :desc])) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      relation.sort_by(:name).reverse.all
    end
  end
end