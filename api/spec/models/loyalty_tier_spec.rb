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
end