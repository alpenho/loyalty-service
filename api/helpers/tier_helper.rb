class TierHelper
  # This is the mapping of tier with the threshold
  TIER_MAPPING = {
    bronze: 0,
    silver: 10000,
    gold: 50000
  }

  # get tier based on the amount
  def self.get_tier(amount)
    return :bronze if amount >= TIER_MAPPING[:bronze] && amount < TIER_MAPPING[:silver]
    return :silver if amount >= TIER_MAPPING[:silver] && amount < TIER_MAPPING[:gold]
    return :gold
  end

  # get next tier by getting the next index from the mapping
  def self.get_next_tier(current_tier)
    tier_keys = TIER_MAPPING.keys
    next_tier_index = tier_keys.index(current_tier.to_sym) + 1

    tier_keys[next_tier_index]
  end
end