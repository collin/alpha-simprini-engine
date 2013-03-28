# coding: utf-8
class Views::Resources::Base < AlphaSimprini::Page
  def resource_name
    resource_class.name
  end

  def html_attrs
    super.merge\
      view:self.class.name.demodulize.underscore,
      controller:self.controller.class.name.demodulize.underscore.gsub('_controller', '')
  end

  def back_link_path
    if respond_to?(:parent?) && parent? && params["id"]
      collection_path
    elsif respond_to?(:parent?) && parent?
      parent_path
    else
      collection_path
    end
  end

  def back_link_text
    if respond_to?(:parent?) && parent? && params["id"]
      [controller.send(:parent).display_name, "'s ", resource_name.pluralize.titlecase].join
    elsif respond_to?(:parent?) && parent?
      controller.send(:parent).display_name
    else
      resource_name.pluralize.titlecase
    end
  end

  def back_link
    # p do
    #   link_to "⇤ back to #{back_link_text} index", back_link_path      
    # end
  end

  def form_for(resource, options={}, &block)
    options[:builder] ||= ::Erector::Rails::FormBuilder.wrapping(NestedForm::SimpleBuilder)
    text(helpers.form_for(resource, options) do |f|
      instance_exec(f, &block) if block_given?  
    end << helpers.send(:after_nested_form_callbacks) )
  end
end