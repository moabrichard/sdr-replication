describe 'Replication::Replica' do

  before(:all) do
    @tmpdir = Pathname(Dir.mktmpdir("replica"))
  end

  after(:all) do
    @tmpdir.rmtree if @tmpdir.exist?
  end

  it '.replica_cache_pathname' do
    expect(Replication::Replica.replica_cache_pathname).to eq nil
    Replication::Replica.replica_cache_pathname = @tmpdir
    expect(Replication::Replica.replica_cache_pathname).to eq @tmpdir
  end

  it '#initialize' do
    replica_id = 'jq937jp0017-v0003'
    home_repository = 'sdr'
    replica = Replica.new(replica_id, home_repository)
    expect(replica).to be_instance_of(Replica)
    expect(replica.replica_id).to eq replica_id
    expect(replica.home_repository).to eq home_repository
    # noinspection RubyArgCount
    expect{ Replica.new }.to raise_exception(ArgumentError, /wrong number of arguments/)
  end

  describe 'instance methods' do
    let(:cache) { @fixtures.join('bags') }
    let(:home_repository) { 'sdr' }
    let(:replica_id) { 'jq937jp0017-v0001' }
    let(:replica) {
      Replication::Replica.replica_cache_pathname = cache
      Replica.new(replica_id, home_repository)
    }

    it '#bag_pathname' do
      expect(replica.bag_pathname).to eq cache.join('sdr/jq937jp0017-v0001')
    end

    it '#get_bag_data' do
      replica.get_bag_data
      expect(replica.create_date).to match(/(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z/)
      expect(replica.payload_size).to eq 275456
      expect(replica.payload_fixity_type).to eq 'sha256'
      expect(replica.payload_fixity).to eq '4aaa02875f4f0690d19ae2d801a470cc71c093c07e7ba3859126c1f846517c1d'
    end

    it '#catalog_replica_data' do
      replica = Replica.new(replica_id, home_repository)
      replica_data = {
        :replica_id => replica_id,
        :home_repository => home_repository,
        :create_date => (replica.create_date = '2014-07-24T06:12:22Z'),
        :payload_size => (replica.payload_size = 275456),
        :payload_fixity_type => (replica.payload_fixity_type = 'sha256'),
        :payload_fixity => (replica.payload_fixity = '4aaa02875f4f0690d19ae2d801a470cc71c093c07e7ba3859126c1f846517c1d')
      }
      expect(ArchiveCatalog).to receive(:add_or_update_item).with(:replicas, replica_data)
      replica.catalog_replica_data
    end
  end
end
