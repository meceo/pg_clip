module SqlFilters
  def quote_literals(input)
    input.map do |item|
      item.is_a?(String) ? "'#{item}'" : item
    end
  end
end

Liquid::Template.register_filter(SqlFilters)
