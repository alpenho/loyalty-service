class LoyaltyTier < ActiveRecord::Base
  enum tier: [ :bronze, :silver, :gold ]

  # get the amount needed for user to the next tier
  def amount_needed_next_tier
    next_tier = TierHelper.get_next_tier(tier)

    next_tier.nil? ? 0 : TierHelper::TIER_MAPPING[next_tier] - total_in_cents
  end

  # get next year tier and return only if the tier is lower than current tier
  def downgrade_tier_next_year
    next_year_tier = TierHelper.get_tier(OrderHelper.calculate_total_a_year(customer_id, year + 1))
    return next_year_tier if TierHelper::TIER_MAPPING[next_year_tier] < TierHelper::TIER_MAPPING[tier.to_sym]
  end

  # get amount needed to get the same tier as current tier
  def calculate_amount_needed_next_year
    next_year_total = OrderHelper.calculate_total_a_year(customer_id, year + 1)
    next_year_tier = TierHelper.get_tier(next_year_total)

    # return 0 if turns out next year the tier is higher or the same as current tier
    return 0 if TierHelper::TIER_MAPPING[next_year_tier] >= TierHelper::TIER_MAPPING[tier.to_sym]

    TierHelper::TIER_MAPPING[tier.to_sym] - next_year_total
  end
end
