class CreateCompletedOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :completed_orders do |t|
      t.string   :order_id
      t.integer  :customer_id
      t.string   :customer_name
      t.float    :total_in_cents
      t.datetime :completed_at

      t.timestamps
    end
  end
end
