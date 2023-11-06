describe LoyaltyTier do
  context '#amount_needed_next_tier' do
    it 'should return correct amount needed for bronze tier' do
      loyalty_tier = described_class.new(customer_id: 'customer_id_1', total_in_cents: 1000, year: 2022, tier: 0)
      expect(loyalty_tier.amount_needed_next_tier).to eql(9000)
    end

    it 'should return correct amount needed for silver tier' do
      loyalty_tier = described_class.new(customer_id: 'customer_id_1', total_in_cents: 12510, year: 2022, tier: 1)
      expect(loyalty_tier.amount_needed_next_tier).to eql(37490)
    end

    it 'should return correct amount needed for gold tier' do
      loyalty_tier = described_class.new(customer_id: 'customer_id_1', total_in_cents: 51000, year: 2022, tier: 2)
      expect(loyalty_tier.amount_needed_next_tier).to eql(0)
    end
  end

  context '#downgrade_tier_next_year' do
    let!(:customer_id) { 'customer_id_1' }
    let!(:completed_order_1) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_1',
        total_in_cents: 3450,
        completed_at: '2023-03-04T05:29:59.850Z'
      )
    }
    let!(:completed_order_2) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_2',
        total_in_cents: 5350,
        completed_at: '2023-03-05T05:29:59.850Z'
      )
    }
    let!(:completed_order_3) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_3',
        total_in_cents: 4670,
        completed_at: '2023-01-05T05:29:59.850Z'
      )
    }

    before do
      completed_order_1.save
      completed_order_2.save
      completed_order_3.save
    end

    it 'should return the downgrade tier for next year' do
      loyalty_tier = described_class.new(customer_id: customer_id, total_in_cents: 55000, year: 2022, tier: 2)
      expect(loyalty_tier.downgrade_tier_next_year).to eql(:silver)
    end

    context 'customer order achieve same tier or higher at next year' do
      let!(:completed_order_4) {
        CompletedOrder.new(
          customer_id: customer_id,
          customer_name: 'customer_name_1',
          order_id: 'order_id_4',
          total_in_cents: 37530,
          completed_at: '2023-03-05T05:29:59.850Z'
        )
      }

      before do
        completed_order_4.save
      end

      it 'should return nil' do
        loyalty_tier = described_class.new(customer_id: customer_id, total_in_cents: 55000, year: 2022, tier: 2)
        expect(loyalty_tier.downgrade_tier_next_year).to eql(nil)
      end
    end
  end

  context '#calculate_amount_needed_next_year' do
    let!(:customer_id) { 'customer_id_1' }
    let!(:completed_order_1) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_1',
        total_in_cents: 3450,
        completed_at: '2023-03-04T05:29:59.850Z'
      )
    }
    let!(:completed_order_2) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_2',
        total_in_cents: 5350,
        completed_at: '2023-03-05T05:29:59.850Z'
      )
    }
    let!(:completed_order_3) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_3',
        total_in_cents: 4670,
        completed_at: '2023-01-05T05:29:59.850Z'
      )
    }

    before do
      completed_order_1.save
      completed_order_2.save
      completed_order_3.save
    end

    it 'should return the amount needed to maintain same tier next year' do
      loyalty_tier = described_class.new(customer_id: customer_id, total_in_cents: 55000, year: 2022, tier: 2)
      expect(loyalty_tier.calculate_amount_needed_next_year).to eql(36530)
    end
  end

  context '.upsert_loyalty_tier' do
    let!(:customer_id) { 'customer_id_1' }
    let!(:last_year) { Time.now.year - 1 }
    let!(:completed_order_1) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_1',
        total_in_cents: 3450,
        completed_at: "#{last_year}-03-04T05:29:59.850Z"
      )
    }
    let!(:completed_order_2) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_2',
        total_in_cents: 5350,
        completed_at: "#{last_year}-03-05T05:29:59.850Z"
      )
    }
    let!(:completed_order_3) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_3',
        total_in_cents: 4670,
        completed_at: "#{last_year}-01-05T05:29:59.850Z"
      )
    }

    before do
      completed_order_1.save
      completed_order_2.save
      completed_order_3.save
    end

    context 'when no loyalty tier for customer last year' do
      it 'should created loyalty tier for last year' do
        described_class.upsert_loyalty_tier(customer_id)
        loyalty_tiers = described_class.where(customer_id: customer_id, year: last_year)
        expect(loyalty_tiers).to exist
        expect(loyalty_tiers.first.total_in_cents).to eql(13470)
      end
    end

    context 'when loyalty tier for customer last year already exist' do
      let!(:completed_order_4) {
        CompletedOrder.new(
          customer_id: customer_id,
          customer_name: 'customer_name_1',
          order_id: 'order_id_4',
          total_in_cents: 5370,
          completed_at: "#{last_year}-01-05T05:29:59.850Z"
        )
      }

      before do
        described_class.upsert_loyalty_tier(customer_id)
        completed_order_4.save
      end

      it 'should update loyalty tier for last year' do
        described_class.upsert_loyalty_tier(customer_id)
        loyalty_tiers = described_class.where(customer_id: customer_id, year: last_year)
        expect(loyalty_tiers).to exist
        expect(loyalty_tiers.first.total_in_cents).to eql(18840)
      end
    end
  end
end