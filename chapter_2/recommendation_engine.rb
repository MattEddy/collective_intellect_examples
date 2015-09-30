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

  def calculalte_similar_items(n = 10)
    result = {}
    transform_preferences

    preferences.each do |item, value|
      result[item] = top_matches(item, 10, lambda(&method(:calculate_euclidean_similarity)))
    end

    result
  end

  def top_matches(person, n = 5, similarity_method = lambda(&method(:calculate_pearson_similarity)))
    (preferences.keys - [person]).map do |critic|
      [similarity_method.call(person, critic), critic]
    end.sort.reverse.first(3)
  end

  def get_recommendations(person)
    adjusted_scores = {}

    (preferences.keys - [person]).each do |critic|
      adjusted_scores[critic] = {}

      preferences[critic].each do |key, value|
        if calculate_pearson_similarity(person, critic) >= 0
          adjusted_scores[critic][key] = calculate_pearson_similarity(person, critic) * value
        end
      end
    end

    summed_ratings = {}
    similarity_sum = {}

    (preferences.keys - [person]).map do |critic|
      preferences[critic].keys.each do |movie|
        unless preferences[person][movie]
          if adjusted_scores[critic][movie]
            if summed_ratings[movie]
              similarity_sum[movie] += calculate_pearson_similarity(person, critic)
              summed_ratings[movie] += adjusted_scores[critic][movie]
            else
              similarity_sum[movie] = calculate_pearson_similarity(person, critic)
              summed_ratings[movie] = adjusted_scores[critic][movie]
            end
          end
        end
      end
    end

    summed_ratings.map do |key, value|
      [value / similarity_sum[key], key]
    end.sort.reverse
  end

  def transform_preferences
    transformed_preferences = {}

    preferences.each do |critic, ratings|
      ratings.each do |movie, score|
        if transformed_preferences[movie]
          transformed_preferences[movie][critic] = score
        else
          transformed_preferences[movie] = { critic => score }
        end
      end
    end

    @preferences = transformed_preferences
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
    (preferences[critic_1][item] - preferences[critic_2][item])
  end

  attr_reader :preferences, :critic_1, :critic_2
end
