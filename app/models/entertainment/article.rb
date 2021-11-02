# frozen_string_literal: true

module Entertainment
  class Article
    include Dynamoid::Document

    field :added_at, :number
    field :title, :string
    field :url, :string

    global_secondary_index hash_key: :url
  end
end
