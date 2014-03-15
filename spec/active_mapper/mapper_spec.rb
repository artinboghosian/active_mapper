require 'spec_helper'
describe ActiveMapper::Mapper do
  let(:adapter) { ActiveMapper::Adapter::Memory.new }
  let(:mapper) { ActiveMapper::Mapper.new(User, adapter) }
  let(:user) { User.new(name: 'user', age: 28) }
  let(:other_user) { User.new(name: 'other', age: 35) }

  before do
    mapper.save(user)
    mapper.save(other_user)
  end

  describe '#all?' do
    it 'is true when all objects match' do
      expect(mapper.all? { |user| user.age > 18 }).to be_true
    end

    it 'is false when all objects do not match' do
      expect(mapper.all? { |user| user.age > 28 }).to be_false
    end
  end

  describe '#any?' do
    it 'is true when any objects match' do
      expect(mapper.any? { |user| user.age == 28 }).to be_true
    end

    it 'is false when no objects match' do
      expect(mapper.any? { |user| user.age > 35 }).to be_false
    end
  end

  describe '#none?' do
    it 'is true when no objects match' do
      expect(mapper.none? { |user| user.age == 18 }).to be_true
    end

    it 'is false when any objects match' do
      expect(mapper.none? { |user| user.age == 28 }).to be_false
    end
  end

  describe '#one?' do
    it 'is true when one object matches' do
      expect(mapper.one? { |user| user.age == 28 }).to be_true
    end

    it 'is false when no objects match' do
      expect(mapper.one? { |user| user.age > 35 }).to be_false
    end

    it 'is false when more than one object matches' do
      expect(mapper.one? { |user| user.age > 18 }).to be_false
    end
  end

  describe '#count' do
    it 'counts the all objects' do
      expect(mapper.count).to eq(2)
    end

    it 'counts matching objects' do
      expect(mapper.count { |user| user.age < 35 }).to eq(1)
    end
  end

  describe '#min' do
    it 'finds the minimum value' do
      expect(mapper.min(:age)).to eq(28)
    end
  end

  describe '#max' do
    it 'finds the maximum value' do
      expect(mapper.max(:age)).to eq(35)  
    end
  end

  describe '#minmax' do
    it 'finds the minium and maximum values' do
      expect(mapper.minmax(:age)).to eq([28, 35])
    end
  end

  describe '#average' do
    it 'finds the average value' do
      expect(mapper.avg(:age)).to eq(31.5)
    end
  end

  describe '#sum' do
    it 'finds the total value' do
      expect(mapper.sum(:age)).to eq(63)
    end
  end

  describe '#find' do
    it 'finds the object with the matching id' do
      expect(mapper.find(user.id)).to eq(user)
    end

    it 'finds no objects with a nil id' do
      expect(mapper.find(nil)).to be_nil
    end

    it 'finds the first matching object' do
      expect(mapper.find { |user| user.age > 21 }).to eq(user)
    end
  end

  describe '#find_all' do
    it 'finds all objects' do
      expect(mapper.find_all.to_a).to eq([user, other_user])
    end

    it 'finds all matching objects' do
      expect(mapper.find_all { |user| user.age < 30 }.to_a).to eq([user])
    end
  end

  describe '#last' do
    it 'finds the last matching object' do
      expect(mapper.last { |user| user.age > 18 }).to eq(other_user)
    end
  end

  describe '#select' do
    it 'finds all matching objects' do
      expect(mapper.select { |user| user.age < 30 }.to_a).to eq([user])
    end
  end

  describe '#reject' do
    it 'finds all non matching objects' do
      expect(mapper.reject { |user| user.age == 28 }.to_a).to eq([other_user])
    end
  end

  describe '#delete' do
    it 'deletes the object' do
      mapper.delete(user)

      expect(mapper.find(user.id)).to be_nil
    end
  end

  describe '#delete_if' do
    it 'deletes all matching objects' do
      mapper.delete_if { |user| user.age == 28 }

      expect(mapper.find(user.id)).to be_nil
      expect(mapper.find(other_user.id)).to eq(other_user)
    end
  end

  describe '#clear' do
    it 'deletes all objects' do
      mapper.clear

      expect(mapper.count).to eq(0)
    end
  end

  describe '#keep_if' do
    it 'deletes all non matching objects' do
      mapper.keep_if { |user| user.age == 28 }

      expect(mapper.find(user.id)).to eq(user)
      expect(mapper.find(other_user.id)).to be_nil
    end
  end

  describe '#save' do
    before { mapper.clear }

    it 'does not save invalid objects' do
      user.stub(valid?: false)
      expect(adapter).to_not receive(:insert)

      expect(mapper.save(user)).to be_false
    end

    it 'creates unpersisted objects that are valid' do
      user.stub(valid?: true)
      user.id = nil

      expect(adapter).to receive(:insert).with(User, user).and_return(1)
      expect { mapper.save(user) }.to change(user, :id)
    end

    it 'updates persisted objects that are valid' do
      user.stub(valid?: true)
      mapper.save(user)

      expect(adapter).to receive(:update).with(User, user)
      expect { mapper.save(user) }.to_not change(user, :id)
    end
  end
end