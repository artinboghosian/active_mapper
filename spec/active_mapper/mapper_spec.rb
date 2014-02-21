require 'spec_helper'

describe ActiveMapper::Mapper do
  let(:adapter) { double('Adapter') }
  let(:mapper) { ActiveMapper::Mapper.new(User, adapter) }
  let(:user) { User.new }

  before { adapter.stub(unserialize: user, where: [user]) }

  describe '#find' do
    it 'finds the object with the matching id' do
      ActiveMapper::Relation.any_instance.should_receive(:all).and_return([user])

      expect(mapper.find(1)).to eq(user)
    end
  end

  describe '#all' do
    it 'finds all matching objects' do
      ActiveMapper::Relation.any_instance.should_receive(:all).and_return([user])

      expect(mapper.all { |user| user.age > 18 }).to eq([user])
    end
  end

  describe '#first' do
    it 'finds the first matching object' do
      ActiveMapper::Relation.any_instance.should_receive(:all).and_return([user])

      expect(mapper.first { |user| user.age > 18 }).to eq(user)
    end
  end

  describe '#last' do
    it 'finds the last matching object' do
      ActiveMapper::Relation.any_instance.should_receive(:all).and_return([user])

      expect(mapper.last { |user| user.age > 18 }).to eq(user)
    end
  end

  describe '#count' do
    it 'counts the matching objects' do
      ActiveMapper::Relation.any_instance.should_receive(:count).and_return(10)

      expect(mapper.count { |user| user.age > 18 }).to eq(10)
    end
  end

  describe '#where' do
    it 'creates a relation object' do
      expect(mapper.where { |user| user.age > 18 }).to be_a(ActiveMapper::Relation)
    end

    pending 'how to verify the correct information was passed to the relation'
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

  describe '#delete' do
    it 'deletes the object' do
      expect(adapter).to receive(:delete).with(User, user)
      mapper.delete(user)
    end
  end

  describe '#delete_all' do
    it 'deletes all matching objects' do
      expect(adapter).to receive(:delete_all).with(User) do |&block|
        expect(block).to be_a(Proc)
      end

      mapper.delete_all { |user| user.age > 18 }
    end
  end
end