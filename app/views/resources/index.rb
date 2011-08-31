class Views::Resources::Index < Views::Resources::Base
  def page_header
    h1 "#{resource_name} Index"
  end
  
  def blank_slate
    link_to "Create a #{resource_name}", new_resource_path
  end
  
  def body_content
    page_header
    item_list
  end
  
  def item_list
    blank_slate
    if collection.any?
      ul do
        collection.each do |item|
          li do
            links_for_item(item)
          end
        end
      end
    end    
  end
  
  def links_for_item(item)
    link_to list_representation(item), resource_path(item)
  end
    
  def list_representation(item)
    if item.respond_to?(:name)
      item.name
    elsif item.respond_to?(:title)
      item.title
    else
      item.to_s
    end
  end
end