require 'spec_helper'

describe ActiveMapper::Relation do
  let(:adapter) { ActiveMapper::Adapter::Memory.new }
  let(:user) { User.new(name: 'user', age: 28) }
  let(:other_user) { User.new(name: 'other', age: 35) }

  before do
    user.id  = adapter.insert(User, user)
    other_user.id = adapter.insert(User, other_user)
  end

  def create_relation(&block)
    ActiveMapper::Relation.new(User, adapter, &block)
  end

  describe '#any?' do
    it 'is true when there are matching objects' do
      relation = create_relation { |user| user.age == 28 }
      expect(relation.any?).to be_true
    end

    it 'is false when there are no matching objects' do
      relation = create_relation { |user| user.age == 18 }
      expect(relation.any?).to be_false
    end
  end

  describe '#none?' do
    it 'is true when there are no matching objects' do
      relation = create_relation { |user| user.age < 18 }

      expect(relation.none?).to be_true
      expect(relation.empty?).to be_true
    end

    it 'is false when there are matching objects' do
      relation = create_relation { |user| user.age == 28 }

      expect(relation.none?).to be_false
      expect(relation.empty?).to be_false
    end
  end

  describe '#one?' do
    it 'is true when there is one matching object' do
      relation = create_relation { |user| user.age == 28 }

      expect(relation.one?).to be_true
    end

    it 'is false when there are no matching objects' do
      relation = create_relation { |user| user.age < 18 }

      expect(relation.one?).to be_false
    end

    it 'is false when there are is more than one matching object' do
      relation = create_relation { |user| user.age > 18 }

      expect(relation.one?).to be_false
    end
  end

  describe '#count' do
    it 'counts the number of matching objects' do
      relation = create_relation { |user| user.age == 28 }

      expect(relation.count).to eq(1)
      expect(relation.length).to eq(1)
      expect(relation.size).to eq(1)
    end
  end

  describe '#min' do
    it 'calculates the minimum value' do
      expect(create_relation.min(:age)).to eql(28)
    end
  end

  describe '#max' do
    it 'calculates the maximum value' do
      expect(create_relation.max(:age)).to eq(35)
    end
  end

  describe '#minmax' do
    it 'calculates the minimum and maximum values' do
      expect(create_relation.minmax(:age)).to eq([28, 35])
    end
  end

  describe '#avg' do
    it 'calculates the average value' do
      expect(create_relation.avg(:age)).to eq(31.5)
    end
  end

  describe '#sum' do
    it 'calculates the total value' do
      expect(create_relation.sum(:age)).to eq(63)
    end
  end

  describe '#drop' do
    it 'offsets by the number of objects' do
      expect(create_relation.drop(1).to_a).to eq([other_user])
    end
  end

  describe '#select' do
    it 'returns matching objects' do
      relation = create_relation { |user| user.name == 'user' }.select { |user| user.age == 28 }.to_a

      expect(relation).to include(user)
      expect(relation).to_not include(other_user)
    end
  end

  describe '#reject' do
    it 'returns non matching objects' do
      relation = create_relation { |user| user.age > 18 }.reject { |user| user.name == 'user' }.to_a

      expect(relation).to include(other_user)
      expect(relation).to_not include(user)
    end
  end

  describe '#first' do
    it 'returns the first matching object' do
      expect(create_relation.first).to eq(user)
    end

    it 'returns the first number of matching objects' do
      expect(create_relation.first(2)).to eq([user, other_user])
    end
  end

  describe '#last' do
    it 'returns the last matching object' do
      expect(create_relation.last).to eq(other_user)
    end

    it 'returns the last number of matching objects' do
      expect(create_relation.last(2)).to eq([other_user, user])
    end
  end

  describe '#take' do
    it 'limits the number of records returned' do
      expect(create_relation.take(1).to_a).to eq([user])
    end
  end

  describe '#to_a' do
    it 'finds all matching objects' do
      expect(create_relation { |user| user.age == 28 }.to_a).to eq([user])
    end
  end

  describe '#map' do
    it 'maps the objects' do
      expect(create_relation.map(&:name)).to eq(['user', 'other'])
    end
  end

  describe '#each' do
    it 'iterates through the objects' do
      create_relation { |user| user.age == 18 }.each { |u| expect(u).to eq(user) }
    end
  end

  describe '#sort_by' do
    it 'sorts the objects by attribute' do
      relation = create_relation.sort_by(&:name).to_a

      expect(relation.first).to eq(other_user)
      expect(relation.last).to eq(user)
    end
  end

  describe '#reverse' do
    it 'sets the opposite direction to order by' do
      relation = create_relation.sort_by(&:age).reverse.to_a

      expect(relation.first).to eq(other_user)
      expect(relation.last).to eq(user)
    end
  end
end