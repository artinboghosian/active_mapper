require 'spec_helper'

describe 'ActiveMapper with Memory adapter' do
  it_should_behave_like 'ActiveMapper Integration', ActiveMapper::Adapter::Memory.new
end