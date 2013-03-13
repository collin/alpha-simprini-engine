class AlphaSimprini::Admin::Resource < AlphaSimprini::Admin::Component
  class_attribute :engine
  class_attribute :model

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