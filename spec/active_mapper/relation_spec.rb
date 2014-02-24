require 'spec_helper'

describe ActiveMapper::Relation do
  let(:adapter) { double('Adapter') }
  let(:user) { User.new(name: 'user', age: 28) }
  let(:query) { proc { |user| user.age > 18 } }
  let(:relation) { ActiveMapper::Relation.new(User, adapter, &query) }

  before { adapter.stub(unserialize: user) }

  describe '#all?' do
    before { expect(adapter).to receive(:count).and_return(10) }

    it 'is true when all objects match' do
      expect(relation).to receive(:count).and_return(10)
      expect(relation.all?).to be_true
    end

    it 'is false when not all objects match' do
      expect(relation).to receive(:count).and_return(9)
      expect(relation.all?).to be_false
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
      expect(relation.empty?).to be_true
    end

    it 'is false when there are matching objects' do
      expect(adapter).to receive(:count).with(User).and_return(1)
      expect(relation.none?).to be_false
      expect(relation.empty?).to be_false
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

  describe '#count' do
    it 'counts the number of matching objects' do
      expect(adapter).to receive(:count).with(User) do |&block|
        expect(block).to eq(query)
      end.and_return(10)

      expect(relation.count).to eq(10)
      expect(relation.length).to eq(10)
      expect(relation.size).to eq(10)
    end
  end

  describe '#drop' do
    it 'offsets by the number of objects' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 10)).and_return([user])

      relation.drop(10).to_a
    end
  end

  describe '#first' do
    it 'returns the first matching object' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 0, limit: 1)).and_return([user])
      expect(relation.first).to eq(user)
    end

    it 'returns the first number of matching objects' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 0, limit: 3)).and_return([user])

      relation.first(3)
    end
  end

  describe '#last' do
    it 'returns the last matching object' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 0, limit: 1, order: [:id, :desc])).and_return([user])
      expect(relation.last).to eq(user)
    end

    it 'returns the last number of matching objects' do
      expect(adapter).to receive(:where).with(User, hash_including(offset: 0, limit: 3, order: [:id, :desc])).and_return([user])

      relation.last(3)
    end
  end

  describe '#take' do
    it 'limits the number of records returned' do
      expect(adapter).to receive(:where).with(User, hash_including(limit: 10)).and_return([user])

      relation.take(10).to_a
    end
  end

  describe '#to_a' do
    it 'finds all matching objects' do
      expect(adapter).to receive(:where).with(User, an_instance_of(Hash)) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      expect(relation.to_a).to eq([user])
    end
  end

  describe '#map' do
    it 'maps the objects' do
      expect(adapter).to receive(:where).with(User, an_instance_of(Hash)).and_return([user])
      expect(relation.map(&:name)).to eq(['user'])
    end
  end

  describe '#each' do
    it 'iterates through the objects' do
      expect(adapter).to receive(:where).and_return([user])
      
      relation.each { |u| expect(u).to eq(user) } 
    end
  end

  describe '#sort' do
    it 'sets the attribute to order by' do
      expect(adapter).to receive(:where).with(User, hash_including(order: [:name, :asc])) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      relation.sort(:name).to_a
    end
  end

  describe '#reverse' do
    it 'sets the opposite direction to order by' do
      expect(adapter).to receive(:where).with(User, hash_including(order: [:name, :desc])) do |&block|
        expect(block).to eq(query)
      end.and_return([user])

      relation.sort_by(:name).reverse.to_a
    end
  end
end