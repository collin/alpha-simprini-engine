module AlphaSimprini::Admin::PathHelpers
  def _uncountable_name(klass=resource_class)
    name = klass.name.singularize
    name.singularize.pluralize == name
  end
end