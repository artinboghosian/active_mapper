require 'spec_helper'

describe 'ActiveMapper with Memory adapter' do
  let(:adapter) { ActiveMapper::Adapter::Memory.new }
  let(:mapper) { ActiveMapper::Mapper.new(User, adapter) }
  let(:user) { User.new(name: 'user', age: 28) }
  let(:other_user) { User.new(name: 'other', age: 35) }

  after { mapper.clear }

  it 'can create and modify records' do
    mapper.save(user)
    user.name = 'Changed'
    user.age = 18
    mapper.save(user)

    record = mapper.find(user.id)

    expect(record.name).to eq('Changed')
    expect(record.age).to eq(18)
  end

  it 'can delete records' do
    mapper.save(user)
    mapper.delete(user)

    expect(mapper.find(user.id)).to be_nil

    user.id = nil

    mapper.save(user)
    mapper.save(other_user)
    mapper.clear

    expect(mapper.count).to eq(0)

    user.id = nil
    other_user.id = nil

    mapper.save(user)
    mapper.save(other_user)
    mapper.delete_if { |user| user.age < 35 }

    expect(mapper.find(other_user.id)).to eq(other_user)
    expect(mapper.find(user.id)).to be_nil

    user.id = nil
    other_user.id = nil

    mapper.save(user)
    mapper.save(other_user)
    mapper.keep_if { |user| user.age < 35 }

    expect(mapper.find(user.id)).to eq(user)
    expect(mapper.find(other_user.id)).to be_nil
  end

  it 'can retrieve the first, last and all records' do
    mapper.save(user)
    mapper.save(other_user)

    expect(mapper.first).to eq(user)
    expect(mapper.last).to eq(other_user)

    records = mapper.find_all.to_a

    expect(records).to include(user)
    expect(records).to include(other_user)
  end

  it 'can count records' do
    mapper.save(user)
    mapper.save(other_user)

    expect(mapper.count).to eq(2)
    expect(mapper.count { |user| user.age < 35 }).to eq(1)
  end

  it 'can query for records' do
    mapper.save(user)
    mapper.save(other_user)

    expect(mapper.reject { |user| user.name == 'user' }.to_a).to eq([other_user])
    expect(mapper.first { |user| user.name.in 'user' }).to eq(user)
    expect(mapper.first { |user| user.name.not_in 'user' }).to eq(other_user)
    expect(mapper.first { |user| user.name.starts_with 'us' }).to eq(user)
    expect(mapper.first { |user| user.name.contains 'th' }).to eq(other_user)
    expect(mapper.first { |user| user.name.ends_with 'er' }).to eq(user)
    expect(mapper.first { |user| user.name == 'user' }).to eq(user)
    expect(mapper.first { |user| user.name != 'user' }).to eq(other_user)
    expect(mapper.first { |user| user.age > 30 }).to eq(other_user)
    expect(mapper.first { |user| user.age >= 35 }).to eq(other_user)
    expect(mapper.first { |user| user.age < 35 }).to eq(user)
    expect(mapper.first { |user| user.age <= 28 }).to eq(user)
    expect(mapper.first { |user| !(user.age == 28) }).to eq(other_user)
    expect(mapper.first { |user| (user.name == 'user') & (user.age > 18) }).to eq(user)
    expect(mapper.first { |user| (user.name == 'other') | (user.age == 35) }).to eq(other_user)
  end

  it 'can aggregate data' do
    mapper.save(user)
    mapper.save(other_user)

    expect(mapper.max(:age)).to eq(35)
    expect(mapper.min(:age)).to eq(28)
    expect(mapper.minmax(:age)).to eq([28, 35])
    expect(mapper.avg(:age)).to eq(31.5)
  end
end