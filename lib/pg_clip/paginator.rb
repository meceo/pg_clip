module PgClip
  class Paginator
    attr_accessor :query

    def initialize(query)
      @query    = query
    end

    def connection
      ActiveRecord::Base.connection
    end

    def records
      execute_query(query).map do |r|
        JSON.parse(r['record'], max_nesting: 1) # it's flat structure
      end
    end

    private

    def execute_query(query)
      connection.execute <<-SQL
        WITH insight AS (#{query})

        SELECT
          row_to_json(insight) AS record
        FROM insight
      SQL
    end

    def execute_paginated_query(query, page: 1, per_page: 1000)
      offset = (page - 1) * per_page

      connection.execute <<-SQL
        WITH insight AS (#{query}), stats AS (
          SELECT
           #{page}                                 AS page,
           COUNT(*)                                AS total_count,
           CEIL(COUNT(*) / #{per_page}::numeric)   AS total_pages
          FROM insight
        )
        SELECT
          stats.*,
          row_to_json(insight) AS record
        FROM insight, stats
        OFFSET #{offset} LIMIT #{per_page};
      SQL
    end
  end
end
