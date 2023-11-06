describe TierHelper do
  context '.get_tier' do
    it 'should return bronze when amount in cents 5000' do
      expect(described_class.get_tier(5000)).to eql(:bronze)
    end

    it 'should return silver when amount in cents 10000' do
      expect(described_class.get_tier(10000)).to eql(:silver)
    end

    it 'should return silver when amount in cents 49999' do
      expect(described_class.get_tier(49999)).to eql(:silver)
    end

    it 'should return gold when amount in cents 50000' do
      expect(described_class.get_tier(50000)).to eql(:gold)
    end
  end

  context '.get_next_tier' do
    it 'should return silver when current tier is bronze' do
      expect(described_class.get_next_tier('bronze')).to eql(:silver)
    end

    it 'should return gold when current tier is silver' do
      expect(described_class.get_next_tier('silver')).to eql(:gold)
    end

    it 'should return nil when current tier is gold' do
      expect(described_class.get_next_tier('gold')).to eql(nil)
    end
  end
end