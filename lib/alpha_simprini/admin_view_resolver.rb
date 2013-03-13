class AlphaSimprini::AdminViewResolver < ::ActionView::Resolver
  def find_templates(name, prefix, partial, details)
    Rails.logger.info "Looking for " + "#{prefix}/views/#{name}".classify
    view = "#{prefix}/views/#{name}".classify.constantize rescue nil
    return [] unless view

    identifier = view.name
    handler = ActionView::Template.registered_template_handler(:alpha_simprini)

    mtime = begin
      Rails.root.join("app", "#{prefix}_admin.rb").mtime
    rescue 
      1.minute.ago
    end

    details = {
      format: Mime[:html],
      # :virtual_path => "#{prefix}_admin.rb",
      updated_at: mtime
    }

    [ActionView::Template.new("", identifier, handler, details)]
  end
end
