class AlphaSimprini::TemplateHandler
  def call(template)
    widget_class_name = template.identifier
    is_partial = false
    <<-SRC
    Erector::Rails.render(#{widget_class_name}, self, local_assigns, #{!!is_partial})
    SRC
  end
end

ActionView::Template.register_template_handler\
  :alpha_simprini, 
  AlphaSimprini::TemplateHandler.new
