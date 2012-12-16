class AlphaSimprini::AdminViewResolver < ::ActionView::Resolver
  def find_templates(name, prefix, partial, details)
    Rails.logger.info "Looking for " + "views/#{prefix}/#{name}".classify
    view = "views/#{prefix}/#{name}".classify.constantize rescue nil
    return [] unless view

    identifier = view.name
    handler = ActionView::Template.registered_template_handler(:alpha_simprini)

    details = {
      :format => Mime[:html],
      # :virtual_path => "#{prefix}_admin.rb",
      :updated_at => Rails.root.join("app", "#{prefix}_admin.rb").mtime
    }

    [ActionView::Template.new("", identifier, handler, details)]
  end
end
