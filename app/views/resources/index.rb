class Views::Resources::Index < Views::Resources::Base
  include Views::Listing

  def self.action_items
    @action_items ||= []
  end
  
  def page_header
    h1 "#{resource_name} Index"
  end
  
  def blank_slate
    link_to "Create a #{resource_name}", new_resource_path, class: 'new'
  end
  
  def body_content
    # page_header
    listing
  end
end