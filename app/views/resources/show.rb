# coding: utf-8
class Views::Resources::Show < Views::Resources::Base
  def self.field(name, &renderer)
    fields[name] = [Class.new(Views::Resources::ShowField), renderer]
  end
  
  def self.has_many(name, &config)
    has_manys[name] = Class.new(Views::Resources::ShowHasMany, &config)
  end

  def self.has_manys
    @has_manys ||= {}
  end  

  def self.fields
    @fields ||= {}
  end

  def body_content
    back_link
    resource_content
    associations_content
    edit_link
  end

  def resource_content
    dl do
      self.class.fields.each do |name, (field, renderer)|
        widget field.new(name: name, renderer:renderer, resource:resource)
      end      
    end
  end  

  def edit_link
    p link_to "edit", edit_resource_path
  end  

  def associations_content
    self.class.has_manys.each do |name, has_many|
      display_relation(name)
    end
  end

  def display_relation(name)
    relation = self.class.has_manys[name]
    widget relation.new(collection: resource.send(name), resource:resource, relation_name:name)
  end
end