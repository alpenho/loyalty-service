class CreateLoyaltyTiers < ActiveRecord::Migration[7.1]
  def change
    create_table :loyalty_tiers do |t|
      t.integer :customer_id
      t.string  :customer_name
      t.float   :total
      t.date    :start_date
      t.date    :end_date
      t.integer :tier

      t.timestamps
    end
  end
end
