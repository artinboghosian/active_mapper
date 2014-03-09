require 'spec_helper'

describe ActiveMapper::Adapter::ActiveRecord::Order do
  let(:order) { described_class.new { |object| [object.name, -object.age] } }

  describe '#to_sql' do
    it 'converts attributes to hash' do
      expect(order.to_sql).to eq({ name: :asc, age: :desc })
    end
  end
end