class Views::Resources::Edit < Views::Resources::Form
  def page_title
    "Edit #{resource_name}"
  end
  
  def form(&block)    
    form_for resource, url: resource_url(resource), &block
  end
end