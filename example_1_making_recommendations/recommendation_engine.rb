class RecommendationEngine
  def initialize(preferences)
    @preferences = preferences
  end

  def calculate_similarity(critic_1, critic_2)
    @critic_1, @critic_2 = critic_1, critic_2

    if common_items.empty?
      return 0
    else
      1.0 / (1.0 + Math.sqrt(find_rating_distance))
    end
  end

  def common_items
    preferences[critic_1].keys & preferences[critic_2].keys
  end

  def find_rating_distance
    common_items.map do |item|
      difference_for_item(item) * difference_for_item(item)
    end.reduce(:+)
  end

  def difference_for_item(item)
    puts "#{item} #{critic_1} #{preferences[critic_1][item]} | #{item} #{critic_2} #{preferences[critic_2][item]}"
    (preferences[critic_1][item] - preferences[critic_2][item])
  end

  attr_reader :preferences, :critic_1, :critic_2
end
