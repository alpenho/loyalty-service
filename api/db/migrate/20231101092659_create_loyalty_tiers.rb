class CreateLoyaltyTiers < ActiveRecord::Migration[7.1]
  def change
    create_table :loyalty_tiers do |t|
      t.string  :customer_id
      t.integer :total_in_cents
      t.integer :year
      t.integer :tier, default: 0

      t.timestamps
    end
  end
end
