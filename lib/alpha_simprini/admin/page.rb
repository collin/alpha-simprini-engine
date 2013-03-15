module AlphaSimprini::Admin::Page
  extend ActiveSupport::Concern
  
  included do
    class_attribute :engine
    class_attribute :component
    script 'alpha_simprini/admin'        
  end

  def _uncountable_name(klass=resource_class)
    name = klass.name.singularize
    name.singularize.pluralize == name
  end

  def header_content
    navigation
  end

  def navigation
    nav do
      engine.sections.map do |subclass|
        next unless subclass.name
        name = subclass.name.demodulize.underscore.gsub /Admin/, ''
        url = if _uncountable_name(subclass)
          send(:"#{name}_index_path".downcase)
        else
          send(:"#{name}_path".downcase)
        end
        attrs = {}
        attrs[:class] = 'current' if request.path.starts_with?(url)
        link_to subclass.tab_text, url, attrs
      end
    end    
  end
end
