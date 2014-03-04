require 'spec_helper'

# NOTE: much of the Memory adapters functionality is
# tested in ActiveMapper::Mapper and ActiveMapper::Relation
# specs. As a result this feature spec focuses on non-tested
# aspects of the Memory adapter.
describe 'ActiveMapper with Memory adapter' do
  let(:adapter) { ActiveMapper::Adapter::Memory.new }
  let(:mapper) { ActiveMapper::Mapper.new(User, adapter) }
  let(:user) { User.new(name: 'user', age: 28) }
  let(:other_user) { User.new(name: 'other', age: 35) }

  before do
    mapper.save(user)
    mapper.save(other_user)
  end

  it 'can query for records' do
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

  it 'can sort records' do
    other_user.age = user.age

    mapper.save(user)
    mapper.save(other_user)
    records = mapper.find_all.sort_by { |user| user.name }.to_a

    expect(records.first).to eq(other_user)
    expect(records.last).to eq(user)

    records = mapper.find_all.sort_by { |user| [user.age, -user.name] }.to_a

    expect(records.first).to eq(user)
    expect(records.last).to eq(other_user)
    
    records = mapper.find_all.sort_by { |user| [user.age, -user.name] }.reverse.to_a

    expect(records.first).to eq(other_user)
    expect(records.last).to eq(user)
  end
end