class OrderHelper
  # get sum of total cent completed order for next year
  def self.calculate_total_a_year(customer_id, year)
    beginning_of_next_year = DateTime.new(year,1,1,0,0,0,'+00:00')
    end_of_next_year = DateTime.new(year,12,31,23,59,59,'+00:00')

    CompletedOrder.where(customer_id: customer_id, completed_at: beginning_of_next_year..end_of_next_year).sum(:total_in_cents)
  end
end