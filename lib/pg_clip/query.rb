module PgClip
  class Query
    def initialize(path)
      @path      = path
      @template  = Dir.chdir(BASE_DIR) { Liquid::Template.parse File.read("#{path}.sql") }
    end

    def per_page
      1000
    end

    def query(params = {})
      @template.render(params.with_indifferent_access)
    end
  end
end
