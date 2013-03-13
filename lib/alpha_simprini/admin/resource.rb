class AlphaSimprini::Admin::Resource < AlphaSimprini::Admin::Component
  class_attribute :engine
  class_attribute :model

  def self.inherited(subclass)
    subclass.class_attribute :scopes
    subclass.scopes = []

    subclass.class_attribute :sortings
    subclass.sortings = []
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

  def self.get_sorting(sorting_name)
    if sorting = sortings.detect{|sorting| sorting.sorting_name.to_s == sorting_name }
      sorting
    else
      sortings.detect{|sorting| sorting.default? }
    end
  end

  def self.generate(engine, model)
    subclass = Class.new(self)
    subclass.engine = engine
    subclass.model = model
    subclass
  end

  def self.namespace
    model.name.demodulize
  end

  def self.index(&config)
    _view :Index, Views::Resources::Index, &config
  end

  def self.show(&config)
    _view :Show, Views::Resources::Show, &config
  end

  def self.new_form(&config)
    _view :New, Views::Resources::New do
      @form_block = config
    end
  end

  def self.edit_form(&config)
    _view :Edit, Class.new(Views::Resources::Edit) do
      @form_block = config
    end
  end
end