require 'spec_helper'
require 'json'

describe RecommendationEngine do
  let(:critics) { File.read(Dir.pwd + "/spec/fixtures/critics.json") }
  let(:data_set) { JSON.parse(critics) }

  describe "#calculate_similarity" do
    it "calculates a similarity score" do
      expect(described_class.new(data_set).calculate_similarity("Lisa Rose", "Gene Seymour"))
        .to eq 0.29429805508554946
    end
  end
end

