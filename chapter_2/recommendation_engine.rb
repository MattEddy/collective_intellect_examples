class RecommendationEngine
  def initialize(preferences)
    @preferences = preferences
  end

  def calculate_euclidean_similarity(critic_1, critic_2)
    @critic_1, @critic_2 = critic_1, critic_2

    if common_items.empty?
      return 0
    else
      1.0 / (1.0 + Math.sqrt(find_rating_distance))
    end
  end

  def top_matches(person, n = 5)
    (preferences.keys - [person]).map do |critic|
      [calculate_pearson_similarity(person, critic), critic]
    end.sort.reverse.first(3)
  end

  def calculate_pearson_similarity(critic_1, critic_2)
    @critic_1, @critic_2 = critic_1, critic_2

    n = common_items.length

    sum1 = rating_for_critic(critic_1) { |rating| rating }
    sum2 = rating_for_critic(critic_2) { |rating| rating }

    sum1Sq = rating_for_critic(critic_1) { |rating| rating ** 2 }
    sum2Sq = rating_for_critic(critic_2) { |rating| rating ** 2 }

    num = sum_of_products - (sum1 * sum2 / n)

    critic_1_adjusted = (sum1Sq - ((sum1 ** 2) / n))
    critic_2_adjusted = (sum2Sq - ((sum2 ** 2) / n))

    den = Math.sqrt(critic_1_adjusted * critic_2_adjusted)

    if den == 0
      0.0
    else
      num / den
    end
  end

  private

  def rating_for_critic(critic, sum = 0.0)
    common_items.map do |item|
      sum += yield preferences[critic][item]
    end

    sum
  end

  def sum_of_products
    common_items.map do |item|
      preferences[critic_1][item] * preferences[critic_2][item]
    end.reduce(:+)
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
