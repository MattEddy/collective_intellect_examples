require 'spec_helper'
require 'json'

describe RecommendationEngine do
  let(:critics) { File.read(Dir.pwd + "/spec/fixtures/critics.json") }
  let(:data_set) { JSON.parse(critics) }

  describe "#calculate_euclidean_similarity" do
    it "calculates a similarity score" do
      expect(described_class.new(data_set).calculate_euclidean_similarity("Lisa Rose", "Gene Seymour"))
        .to eq 0.29429805508554946
    end
  end

  describe "#calculate_pearson_similarity" do
    it "calculates a similarity score" do
      expect(described_class.new(data_set).calculate_pearson_similarity("Lisa Rose", "Gene Seymour"))
        .to eq 0.39605901719066977
    end
  end

  describe "#top_matches" do
    it "calculates top similar critics for a given critic" do
      expect(described_class.new(data_set).top_matches('Toby', 3)).to eq [
        [0.99124070716192991, 'Lisa Rose'],
        [0.92447345164190486, 'Mick LaSalle'],
        [0.89340514744156474, 'Claudia Puig']
      ]
    end
  end

  describe "#get_recommendations" do
    it "recommends movies for a given critic" do
      expect(described_class.new(data_set).get_recommendations('Toby')).to eq [
        [3.3477895267131017, 'The Night Listener'],
        [2.8325499182641614, 'Lady in the Water'],
        [2.530980703765565, 'Just My Luck']
      ]
    end
  end

  describe "#transform_preferences" do
    it "switches preferences from a list of critics to a list of movies" do
      expect(described_class.new(data_set).transform_preferences['Lady in the Water']).to eq ({
        "Lisa Rose"        => 2.5,
        "Gene Seymour"     => 3.0,
        "Michael Phillips" => 2.5,
        "Mick LaSalle"     => 3.0,
        "Jack Matthews"    => 3.0
      })
    end
  end

  describe "#calculalte_similar_items" do
    it "returns a dictionary of similar items" do
      expect(described_class.new(data_set).calculalte_similar_items['Lady in the Water']).to eq [[0.4494897427831781, "You, Me and Dupree"],
        [0.38742588672279304, "The Night Listener"],
        [0.3483314773547883, "Snakes on a Plane"]
      ]
    end
  end
end


