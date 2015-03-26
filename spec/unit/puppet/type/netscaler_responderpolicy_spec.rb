#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :netscaler_responderpolicy
res_type = Puppet::Type.type(res_type_name)

describe res_type do
#create setting name type target bypasssafetycheck comment
    let(:provider) {
    prov = stub 'provider'
    prov.stubs(:name).returns(res_type_name)
    prov
  }
  let(:res_type) {
    type = res_type
    type.stubs(:defaultprovider).returns provider
    type
  }
  let(:resource) {
    res_type.new({:name => 'test_node'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

# set responderpolicy to something else
# remove a provideraction
end
