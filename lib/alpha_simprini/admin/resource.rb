class AlphaSimprini::Admin::Resource < AlphaSimprini::Admin::Component
  # def self.inherited(subclass); end

  def self.search(*fields)
    self.search_fields += fields
  end

  def self.apply_search(query, search_string)
    clause = model.arel_table[search_fields.first].matches("%#{search_string}%")
    search_fields.each_with_index do |field, index|
      next if index.zero?
      clause = clause.or(model.arel_table[field].matches("%#{search_string}%"))
    end
    query.where(clause)
  end

  def self.filter(filter_name, display_name=nil, options)
    display_name ||= filter_name.to_s.titlecase
    self.filters << AlphaSimprini::Admin::Filter.new(self, filter_name, display_name, options)
  end

  def self.sort(sort_name, display_name=nil, options={})
    display_name ||= sort_name.to_s.titlecase
    self.sortings << AlphaSimprini::Admin::Sorting.new(self, sort_name, display_name, options)
  end

  def self.scope(scope_name, display_name=nil, options={})
    display_name ||= scope_name.to_s.titlecase
    self.scopes << AlphaSimprini::Admin::Scope.new(self, scope_name, display_name, options)
  end

  def self.get_scope(scope_name)
    scopes.detect{|scope| scope.scope_name.to_s == scope_name }
  end

  def self.get_filters(filter_keys)
    filters.find_all{|filter| filter_keys.include? filter.param_name.to_s }
  end

  def self.get_sorting(sorting_name)
    if sorting = sortings.detect{|sorting| sorting.sorting_name.to_s == sorting_name }
      sorting
    else
      sortings.detect{|sorting| sorting.default? }
    end
  end
end