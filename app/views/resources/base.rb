class Views::Resources::Base < AlphaSimprini::Page
  def resource_name
    resource_class.name
  end

  def html_attrs
    super.merge view:self.class.name.demodulize.underscore
  end
end