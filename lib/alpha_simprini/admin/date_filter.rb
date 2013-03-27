class AlphaSimprini::Admin::DateFilter
  class Model
    attr_accessor :from, :until

    include ActiveModel::Conversion
    extend ActiveModel::Naming
    include ActiveRecord::AttributeAssignment

    attr_accessible :from, :until

    def initialize(param_name, attributes)
      @param_name = param_name
      self.attributes = attributes
    # rescue 
      # Don't really mind failure on attribute assignment.
      # It just means we're blank
    end

    def persisted?; false end

    def to_key; [@param_name] end

    def self.reflect_on_aggregation(name) 
      Module.new{def self.klass; Date end}
    end

    def column_for_attribute(name)
      Module.new{def self.klass; Date end}
    end

    def self.create_time_zone_conversion_attribute?(name, column); end

    def self.default_timezone
      :utc
    end
  end

  attr_accessor :display_name, :from_param_name, :until_param_name

  def initialize(component, column_name, display_name, options)
    @component = component
    @column_name = column_name
    @display_name = display_name
    @options = options
  end

  def active_model(params)
    Model.new(param_name, params)
  end

  def param_name
    @param_name ||= :"date_filter_#{@column_name}"
  end

  def from_date(param)
    MultiParameterAttribute.new(:from, param, -> { default_from_date }).to_date
  end

  def until_date(param)
    MultiParameterAttribute.new(:until, param, -> { default_until_date }).to_date
  end

  def arel_column
    @component.model.arel_table[@column_name]
  end

  def apply_to(query, param)
    query.where arel_column.gt(from_date(param).to_date).and( arel_column.lt(until_date(param).to_date) )
  end

  def path_options(param)
    {
      @param_name => {}.tap do |hash|
        hash.merge from_date(param).to_param unless default_from_date?(param)
        hash.merge until_date(param).to_param unless default_until_date?(param)
      end
    }
  end

  def default_from_date
    Time.now.beginning_of_month
  end

  def default_until_date
    Time.now.end_of_month
  end

  def default_from_date?(param)
    from_date(param).to_date == default_from_date
  end

  def default_until_date?(param)
    until_date(param).to_date == default_until_date
  end

  class MultiParameterAttribute
    def initialize(name, params, default_date)
      @name = name
      @attributes = {}
      @default_date = default_date || -> { Time.now }
      
      params.keys.grep(%r{#{name}\(\di\)}).each do |key|
        @attributes[key] = params[key].dup
      end
    end

    def to_param
      date = to_date
      return {
        "#{@name}(1i)" => date.year,
        "#{@name}(2i)" => date.month,
        "#{@name}(3i)" => date.day
      }
    end

    def to_date
      Date.civil(
        @attributes["#{@name}(1i)"].try(:to_i),
        @attributes["#{@name}(2i)"].try(:to_i),
        @attributes["#{@name}(3i)"].try(:to_i)
      )
    rescue
      @default_date.call
    end
  end
end