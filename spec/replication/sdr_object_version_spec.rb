describe 'Replication::SdrObjectVersion' do

  it '#initialize' do
    sdr_object = SdrObject.new("druid:jq937jp0017")
    sdr_object_version = SdrObjectVersion.new(sdr_object, 1)
    expect(sdr_object_version).to be_instance_of SdrObjectVersion
  end

  before(:all) do
    @druid = "druid:jq937jp0017"
    @sdr_object = SdrObject.new(@druid)
    @sdr_object_version = SdrObjectVersion.new(@sdr_object, 1)
    Replica.replica_cache_pathname = Pathname(Dir.mktmpdir("replica_cache"))
  end

  it '#digital_object_id' do
    expect(@sdr_object_version.digital_object_id).to eq @druid
  end

  it '#sdr_version_id' do
    expect(@sdr_object_version.version_id).to eq 1
  end

  it '#version_inventory' do
    vi = @sdr_object_version.file_inventory('version')
    expect(vi).to be_instance_of Moab::FileInventory
    expect(vi.file_count).to eq 12
  end

  it '#version_additions' do
    va = @sdr_object_version.file_inventory('additions')
    expect(va).to be_instance_of Moab::FileInventory
  end

  it '#parse_version_metadata' do
    vm = @sdr_object_version.parse_version_metadata
    expect(vm).to eq({ :version_id => 1 })
  end

  it '#parse_identity_metadata' do
    vm = @sdr_object_version.parse_identity_metadata
    expect(vm).to eq({
      :object_type => "item",
      :object_label => "Google Scanned Book, barcode 36105024276136"
    })
  end

  it '#parse_relationship_metadata' do
    vm = @sdr_object_version.parse_relationship_metadata
    expect(vm).to eq({ :governed_by => "druid:wk434ht4838" })
  end

  it '#catalog_object_data' do
    digital_object_data = {
      :digital_object_id => "druid:jq937jp0017",
      :home_repository => "sdr"
    }
    sdr_object_data = {
      :sdr_object_id => "druid:jq937jp0017",
      :object_type => "item",
      :object_label => "Google Scanned Book, barcode 36105024276136",
      :governing_object => "druid:wk434ht4838",
      :latest_version => 3
    }

    @sdr_object_version.version_id = 1
    expect(ArchiveCatalog).to receive(:add_or_update_item).with(:digital_objects, digital_object_data)
    expect(ArchiveCatalog).to receive(:add_or_update_item).with(:sdr_objects, sdr_object_data)
    @sdr_object_version.catalog_object_data

    sdr_object_version_2 = SdrObjectVersion.new(@sdr_object, 2)
    expect(ArchiveCatalog).to receive(:update_item).with(:sdr_objects, @druid, sdr_object_data)
    sdr_object_version_2.catalog_object_data
  end

  it '#catalog_version_data' do
    sdr_object_version_data = {
      :sdr_object_id => "druid:jq937jp0017",
      :sdr_version_id => 2,
      :replica_id => "druid:jq937jp0017-v0002",
      :ingest_date => "2012-11-13T22:23:48Z"
    }
    sdr_version_full = {
      :sdr_object_id => "druid:jq937jp0017",
      :sdr_version_id => 2,
      :inventory_type => "full",
      :content_files => 4,
      :content_bytes => 132363,
      :content_blocks => 131,
      :metadata_files => 6,
      :metadata_bytes => 6676,
      :metadata_blocks => 9
    }
    sdr_version_delta = {
      :sdr_object_id => "druid:jq937jp0017",
      :sdr_version_id => 2,
      :inventory_type => "delta",
      :content_files => 1,
      :content_bytes => 32915,
      :content_blocks => 33,
      :metadata_files => 3,
      :metadata_bytes => 2266,
      :metadata_blocks => 4
    }
    sdr_object_version = SdrObjectVersion.new(@sdr_object, 2)
    expect(ArchiveCatalog).to receive(:add_or_update_item).with(:sdr_object_versions, sdr_object_version_data)
    expect(ArchiveCatalog).to receive(:add_or_update_item).with(:sdr_version_stats, sdr_version_full)
    expect(ArchiveCatalog).to receive(:add_or_update_item).with(:sdr_version_stats, sdr_version_delta)
    sdr_object_version.catalog_version_data
  end

  it '#replica' do
    replica = @sdr_object_version.replica
    expect(replica).to be_instance_of Replica
    expect(replica.replica_id).to eq 'jq937jp0017-v0001'
    expect(replica.home_repository).to eq 'sdr'
    expect(replica.bag_pathname).to eq Replica.replica_cache_pathname.join("sdr/jq937jp0017-v0001")
  end

  # Unit test for method: {Replication::SdrObjectVersion#create_replica}
  # Which returns: [BagitBag] Copy the object version into a BagIt Bag in tarfile format
  # For input parameters: (None)
  specify 'Replication::SdrObjectVersion#create_replica' do
    replica = @sdr_object_version.create_replica
    expect(replica).to be_instance_of Replica
    bag = replica.bagit_bag
    expect(bag.bag_pathname).to eq Replica.replica_cache_pathname.join("sdr/jq937jp0017-v0001")
    expect(bag.verify_bag).to eq true

    # Check that it will not overwrite an existing replica
    expect{ @sdr_object_version.create_replica }.to raise_error(Replication::ReplicaExistsError)
    Replica.replica_cache_pathname.rmtree
  end
end
