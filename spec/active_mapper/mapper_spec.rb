require 'spec_helper'
describe ActiveMapper::Mapper do
  let(:adapter) { double('Adapter') }
  let(:mapper) { ActiveMapper::Mapper.new(User, adapter) }
  let(:user) { User.new }

  before { adapter.stub(unserialize: user, where: [user]) }

  describe '#all?' do
    pending 'how to test'
  end

  describe '#any?' do
    it 'is true when any objects match' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(1)

      expect(mapper.any?).to be_true
    end

    it 'is false when no objects match' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(0)

      expect(mapper.any?).to be_false
    end
  end

  describe '#none?' do
    it 'is true when no objects match' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(0)

      expect(mapper.none?).to be_true
    end

    it 'is false when any objects match' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(1)

      expect(mapper.none?).to be_false
    end
  end

  describe '#one?' do
    it 'is true when one object matches' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(1)

      expect(mapper.one?).to be_true
    end

    it 'is false when no objects match' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(0)

      expect(mapper.one?).to be_false
    end

    it 'is false when more than one object matches' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(2)

      expect(mapper.one?).to be_false
    end
  end

  describe '#count' do
    it 'counts the matching objects' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(10)

      expect(mapper.count).to eq(10)
    end
  end

  describe '#min' do
    it 'finds the minimum value' do
      expect(adapter).to receive(:min).with(User, :age).and_return(28)
      expect(mapper.min(:age)).to eq(28)
    end
  end

  describe '#max' do
    it 'finds the maximum value' do
      expect(adapter).to receive(:max).with(User, :age).and_return(35)
      expect(mapper.max(:age)).to eq(35)  
    end
  end

  describe '#minmax' do
    it 'finds the minium and maximum values' do
      expect(adapter).to receive(:min).with(User, :age).and_return(28)
      expect(adapter).to receive(:max).with(User, :age).and_return(35)
      expect(mapper.minmax(:age)).to eq([28, 35])
    end
  end

  describe '#find' do
    it 'finds the object with the matching id' do
      ActiveMapper::Relation.any_instance.should_receive(:to_a).and_return([user])

      expect(mapper.find(1)).to eq(user)
    end

    it 'finds the first matching object' do
      ActiveMapper::Relation.any_instance.should_receive(:to_a).and_return([user])

      expect(mapper.find { |user| user.age > 21 }).to eq(user)
    end
  end

  describe '#find_all' do
    it 'finds all matching objects' do
      ActiveMapper::Relation.any_instance.should_receive(:to_a).and_return([user])

      expect(mapper.find_all { |user| user.age > 18 }.to_a).to eq([user])
    end
  end

  describe '#last' do
    it 'finds the last matching object' do
      ActiveMapper::Relation.any_instance.should_receive(:to_a).and_return([user])

      expect(mapper.last { |user| user.age > 18 }).to eq(user)
    end
  end

  describe '#select' do
    pending 'how to test'
  end

  describe '#reject' do
    pending 'how to test'
  end

  describe '#delete' do
    it 'deletes the object' do
      expect(adapter).to receive(:delete).with(User, user)
      mapper.delete(user)
    end
  end

  describe '#delete_if' do
    it 'deletes all matching objects' do
      expect(adapter).to receive(:delete_all).with(User) do |&block|
        expect(block).to be_a(Proc)
      end

      mapper.delete_if { |user| user.age > 18 }
    end
  end

  describe '#clear' do
    it 'deletes all objects' do
      expect(adapter).to receive(:delete_all).with(User) do |&block|
        expect(block).to be_nil
      end

      mapper.clear
    end
  end

  describe '#keep_if' do
    pending 'how to test'
  end

  describe '#save' do
    it 'does not save invalid objects' do
      user.stub(valid?: false)
      expect(adapter).to_not receive(:insert)

      mapper.save(user)
    end

    it 'creates unpersisted objects that are valid' do
      user.stub(valid?: true)

      expect(adapter).to receive(:insert).with(User, user).and_return(1)
      expect { mapper.save(user) }.to change(user, :id).to eq(1)
    end

    it 'updates persisted objects that are valid' do
      user.stub(valid?: true)
      user.id = 1

      expect(adapter).to receive(:update).with(User, user)
      expect { mapper.save(user) }.to_not change(user, :id)
    end
  end
end