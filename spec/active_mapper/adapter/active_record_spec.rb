require 'spec_helper'

describe ActiveMapper::Adapter::ActiveRecord do
  let(:user) { User.new(name: 'user', age: 28) }
  let(:other_user) { User.new(name: 'other', age: 35) }
  let(:adapter) { ActiveMapper::Adapter::ActiveRecord.new }

  setup_active_record('active_record')

  before do
    user.id = adapter.insert(User, user)
    other_user.id = adapter.insert(User, other_user)
  end

  after { adapter.delete_all(User) }

  describe '#find' do
    it 'finds the record with the matching id' do
      record = adapter.find(User, user.id)

      expect(record.id).to eq(user.id)
    end
  end

  describe '#where' do
    it 'finds the matching records' do
      ids = adapter.where(User) { |u| u.age < 35 }.load.map(&:id)

      expect(ids).to include(user.id)
      expect(ids).to_not include(other_user.id)
    end

    it 'finds and sorts the matching records in ascending order' do
      records = adapter.where(User, order: [:name, :asc])

      expect(records.first.id).to eq(other_user.id)
      expect(records.last.id).to eq(user.id)
    end

    it 'finds and sorts the matching records in descending order' do
      records = adapter.where(User, order: [:age, :desc])

      expect(records.first.id).to eq(other_user.id)
      expect(records.last.id).to eq(user.id)
    end

    it 'limits the number of matching records' do
      records = adapter.where(User, limit: 1)

      expect(records.count).to eq(1)
    end

    it 'offsets the matching records' do
      ids = adapter.where(User, offset: 1).load.map(&:id)

      expect(ids).to include(other_user.id)
      expect(ids).to_not include(user.id)
    end
  end

  describe '#count' do
    it 'counts the number of total records' do
      expect(adapter.count(User)).to eq(2)
    end

    it 'counts the number of matching records' do
      expect(adapter.count(User) { |u| u.age < 35 }).to eq(1)
    end
  end

  describe '#minimum' do
    it 'calculates the minimum value' do
      expect(adapter.minimum(User, :age)).to eq(28)
    end

    it 'calculates the minimum value of a subset of records' do
      expect(adapter.minimum(User, :age) { |user| user.age > 30 }).to eq(35)
    end
  end

  describe '#maximum' do
    it 'calculates the maximum value' do
      expect(adapter.maximum(User, :age)).to eq(35)
    end

    it 'calculates the maximum value of a subset of records' do
      expect(adapter.maximum(User, :age) { |user| user.age < 30 }).to eq(28)
    end
  end

  describe '#average' do
    it 'calculates the average value' do
      expect(adapter.average(User, :age)).to eq(31.5)
    end

    it 'calculates the avarage value of a subset of records' do
      expect(adapter.average(User, :age) { |user| user.age < 35 }).to eq(28)
    end
  end

  describe '#insert' do
    it 'inserts the record into the database' do
      user = User.new(name: 'test', age: 18)
      id = adapter.insert(User, user)
      record = adapter.find(User, id)

      expect(record.id).to eq(id)
    end
  end

  describe '#update' do
    it 'updates the record in the database' do
      user.name = 'Changed'
      user.age = 18
      adapter.update(User, user)
      record = adapter.find(User, user.id)

      expect(record.name).to eq('Changed')
      expect(record.age).to eq(18)
    end
  end

  describe '#delete' do
    it 'deletes the record from the database' do
      adapter.delete(User, user)

      expect(adapter.find(User, user.id)).to be_nil
    end
  end

  describe '#delete_all' do
    it 'deletes all the records' do
      adapter.delete_all(User)

      expect(adapter.count(User)).to eq(0)
    end

    it 'deletes the matching records' do
      adapter.delete_all(User) { |u| u.name == 'user' }

      expect(adapter.find(User, user.id)).to be_nil
      expect(adapter.find(User, other_user.id)).to_not be_nil
    end
  end

  describe '#unserialize' do
    it 'unserializes the object' do
      record = adapter.find(User, user.id)
      unserialized = adapter.unserialize(User, record)

      expect(unserialized).to eq(user)
    end
  end
end