class Views::Resources::ShowHasMany < AlphaSimprini::Widget
  include Views::Listing
  include AlphaSimprini::Admin::ActionItems
  
  no_actions!

  attr_accessor :collection, :relation_name, :resource

  def self.nested(value=nil)
    value.nil? or @nested = value
    return @nested
  end

  class << self
    alias nested? nested
  end

  def blank_slate
    return if collection.any?
    p class:'lead' do
      text "There are none."
    end
  end

  def content
    section class: ['has-many', relation_name] do    
      h3 header_text if header_text.present?
      listing
    end
  end

  def collection_name
    name = super
    if name.blank?
      relation_name.to_s.titlecase
    else
      name
    end
  end

  delegate :relation_form, to: 'self.class'

  def _resource_path(item)
    resource_path([resource, relation_name, item])
  end

  def _edit_resource_path(item)
    edit_resource_path([resource, relation_name, item])
  end

  def link_to_create
    return unless create?
    if self.class.nested?
      form_for resource do |f|
        f.fields_for(relation_name) do |fields|
          instance_exec fields, &relation_form.form_block        
        end
                
        f.link_to_add\
          "Add a #{collection_name.titlecase.singularize}",
          relation_name, class:'create'
      end
    else
      link_to\
        "Add a #{collection_name.titlecase.singularize}",
        url_for([:new, resource, relation_name.to_s.singularize]),
        class: 'btn'
    end
  end

  def form_for(resource, options={}, &block)
    options[:builder] ||= FormBuilder.wrapping(NestedForm::SimpleBuilder)
    text(helpers.form_for(resource, options) do |f|
      instance_exec(f, &block) if block_given?  
    end << helpers.send(:after_nested_form_callbacks) )
  end

  def self.form(&block)
    @relation_form = Class.new(Views::Resources::RelationForm)
    @relation_form.form(&block)
    @relation_form
  end

  def self.relation_form
    @relation_form
  end
end

class Views::Resources::RelationForm < Views::Resources::Form
end