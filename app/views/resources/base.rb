class Views::Resources::Base < AlphaSimprini::Page
  def resource_name
    resource_class.name
  end
end