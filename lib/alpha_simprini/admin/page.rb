module AlphaSimprini::Admin::Page
  extend ActiveSupport::Concern
  included do
    class_attribute :engine
    class_attribute :component
    script 'alpha_simprini/admin'        
  end

  def resource_path(_resource=resource, options={})
    polymorphic_path _resource, options
  end

  def new_resource_path(options={})
    polymorphic_path resource_class, {action:'new'}.reverse_merge(options)
  end

  def edit_resource_path(_resource=resource, options={})
    polymorphic_path _resource, {action:'edit'}.reverse_merge(options)
  end

  def collection_path(options={})
    polymorphic_path resource_class, options
  end

  def header_content
    label :application_title
    navigation
  end

  def navigation
    nav do
      engine.sections.map do |subclass|
        next unless subclass.name
        name = subclass.name.demodulize.underscore.gsub /Admin/, ''
        url = send(:"#{name}_path".downcase)
        attrs = {}
        attrs[:class] = 'current' if request.path.starts_with?(url)
        link_to subclass.tab_text, url, attrs
      end
    end    
  end
end
