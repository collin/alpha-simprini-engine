module AlphaSimprini::Admin::Page
  extend ActiveSupport::Concern
  included do
    script 'alpha_simprini/admin'        
  end

  def resource_path(_resource=resource)
    polymorphic_path _resource
  end

  def new_resource_path
    polymorphic_path resource_class, action:'new'
  end

  def edit_resource_path(_resource=resource)
    polymorphic_path _resource, action:'edit'
  end

  def collection_path
    polymorphic_path resource_class
  end

  def header_content
    label :application_title
    navigation
  end

  def navigation
    nav do
      names = ApplicationAdmin.sections.map do |subclass|
        next unless subclass.name
        subclass.name.demodulize.gsub /Admin/, ''
      end
      names.uniq!
      names.compact!
      names.each do |name|
        url = send(:"#{name}_path".downcase)
        attrs = {}
        attrs[:class] = 'current' if current_page?(url)
        link_to name, url, attrs
      end        
    end    
  end
end
