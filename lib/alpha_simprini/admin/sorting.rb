class AlphaSimprini::Admin::Sorting
  attr_accessor :display_name, :sorting_name

  def initialize(component, sorting_name, display_name, options={})
    @component = component
    @sorting_name = sorting_name
    @display_name = display_name
    @default = options[:default] || false
  end

  def default?; @default end

  def matches(sorting=nil)
    sorting.nil? and return true if default?
    return sorting == sorting_name.to_s
  end

  def path_options
    if default?
      {}
    else
      {sort:sorting_name}
    end
  end

  def apply_to(query, direction)
    return query unless ["asc", "desc"].include?(direction)
    query.order [sorting_name, direction] * " "
  end
end
