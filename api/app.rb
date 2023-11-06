ActiveRecord::Base.configurations = YAML.safe_load_file('config/database.yml', aliases: true)
ActiveRecord::Base.establish_connection(:development)

Dir['models/*.rb'].each { |file| require_relative file }
Dir['helpers/*.rb'].each { |file| require_relative file }

class LoyaltyServiceAPI < Sinatra::Base
  use Rack::JSONBodyParser
  helpers Sinatra::Param

  before do
    content_type :json
  end

  get '/' do
    'Hello Worlds!'
  end

  post '/order_completed' do
    param :customerId,   String,   required: true
    param :customerName, String,   required: true
    param :orderId,      String,   required: true
    param :totalInCents, Integer,  required: true
    param :date,         DateTime, required: true

    completed_order = CompletedOrder.new(
      customer_id: params[:customerId],
      customer_name: params[:customerName],
      order_id: params[:orderId],
      total_in_cents: params[:totalInCents],
      completed_at: params[:date]
    )
    ActiveRecord::Base.transaction do
      completed_order.save
    end

    json completed_order
  end

  get '/:customer_id/tier' do
    current_year = Time.now.year
    loyalty_tier = LoyaltyTier.where(customer_id: params[:customer_id], year: current_year - 1).first
    result = {
      current_tier: loyalty_tier.tier,
      start_date: DateTime.new(loyalty_tier.year,1,1,0,0,0,'+00:00'),
      amount_spent: loyalty_tier.total_in_cents,
      amount_needed: loyalty_tier.amount_needed_next_tier,
      downgrade_tier: loyalty_tier.downgrade_tier_next_year,
      downgrade_tier_date: DateTime.new(loyalty_tier.year + 1,1,1,0,0,0,'+00:00'),
      amount_needed_next_year: loyalty_tier.calculate_amount_needed_next_year
    }

    json result
  end

  get '/:customer_id/orders' do
    current_year = Time.now.year
    beginning_of_next_year = DateTime.new(current_year - 1,1,1,0,0,0,'+00:00')
    end_of_next_year = DateTime.new(current_year - 1,12,31,23,59,59,'+00:00')

    completed_orders = CompletedOrder.where(customer_id: params[:customer_id], completed_at: beginning_of_next_year..end_of_next_year).all

    json completed_orders
  end
end
