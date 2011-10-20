class Views::Resources::New < Views::Resources::Form
  def page_title
    "New #{resource_name}"
  end
  
  def form &block
    form_for resource, url: collection_url, &block
  end
end