describe OrderHelper do
  context '.calculate_total_a_year' do
    let!(:customer_id) { 'customer_id_1' }
    let!(:completed_order_1) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_1',
        total_in_cents: 3450,
        completed_at: '2022-03-04T05:29:59.850Z'
      )
    }
    let!(:completed_order_2) {
      CompletedOrder.new(
        customer_id: customer_id,
        customer_name: 'customer_name_1',
        order_id: 'order_id_2',
        total_in_cents: 5350,
        completed_at: '2022-03-05T05:29:59.850Z'
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

    it 'should return correct total' do
      expect(described_class.calculate_total_a_year(customer_id, 2022)).to eql(completed_order_1.total_in_cents + completed_order_2.total_in_cents)
      expect(described_class.calculate_total_a_year(customer_id, 2023)).to eql(completed_order_3.total_in_cents)
    end
  end
end