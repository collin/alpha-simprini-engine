class AlphaSimprini::Admin::Scope
  attr_accessor :display_name, :scope_name

  def initialize(component, scope_name, display_name, options)
    @component = component
    @scope_name = scope_name
    @display_name = display_name
    @options = options
  end

  def matches(scope=nil)
    return true if scope.nil? && @options[:default]
    return scope == scope_name.to_s
  end

  def path_options
    if @options[:default]
      {}
    else
      {scope:scope_name}
    end
  end

  def apply_to(query)
    if scope_name == :all
      query
    else
      query.send(scope_name)
    end  
  end

  def count(query)
    apply_to(query).count
  end
end
