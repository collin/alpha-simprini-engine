class AlphaSimprini::Admin::Filter
  attr_accessor :display_name, :filter_name

  def initialize(component, filter_name, display_name, options)
    @component = component
    @filter_name = filter_name
    @display_name = display_name
    @options = options
  end

  def param_name
    @param_name ||= :"filter_#{filter_name}"
  end

  def include_blank?
    @options[:include_blank]
  end

  def options_for_select
    @options[:collection].map do |item|
      [item.send(@options[:display_field]), item.id]
    end
  end

  def apply_to(query, value)
    query.where(filter_name => value)
  end

  # def path_options
  #   if filter_name == :all
  #     {}
  #   else
  #     { :"filter_#{filter_name}": }
  #   end
  # end

  # def apply_to(query)
  #   query.send(filter_name)
  # end

  # def count(query)
  #   apply_to(query).count
  # end

end