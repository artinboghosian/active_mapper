require 'spec_helper'

describe 'ActiveMapper with ActiveRecord adapter' do
  setup_database('arel_integration')

  it_should_behave_like 'ActiveMapper Integration', ActiveMapper::Adapter::Arel.new
end