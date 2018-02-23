require 'spec_helper'

describe 'Replication::SdrObject' do
  it '#initialize' do
    druid = "druid:jq937jp0017"
    sdr_object = SdrObject.new(druid)
    expect(sdr_object).to be_instance_of(SdrObject)
    expect(sdr_object.digital_object_id).to eq druid
    expect(sdr_object.object_pathname).to eq Pathname(@fixtures).join('moab-objects',druid.split(/:/).last)
    expect(sdr_object.storage_root).to eq Pathname(@fixtures)
  end
end
