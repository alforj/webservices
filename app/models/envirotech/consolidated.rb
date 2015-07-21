module Envirotech
  class Consolidated
    include Searchable
    self.model_classes = [Envirotech::Solution,
                          Envirotech::Issue,
                          Envirotech::Regulation,
                          Envirotech::Provider,
                          Envirotech::AnalysisLink]
  end
end
