require 'spec_helper'

describe 'ActiveMapper with ActiveRecord adapter' do
  setup_active_record('active_record_integration')

  it_should_behave_like 'ActiveMapper Integration', ActiveMapper::Adapter::Arel.new
end