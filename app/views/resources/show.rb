class Views::Resources::Show < Views::Resources::Base
  cattr_accessor :has_manys
  
  def self.has_manys
    @has_manys ||= {}
  end
  
  def self.has_many(name, &config)
    has_manys[name] = Views::Resources::ShowHasMany.new(&config)
  end

  def back_link
    p link_to "back to #{resource_name.pluralize} index", collection_path      
  end

  def body_content
    back_link
    resource_content
    associations_content
    edit_link
  end

  def resource_content
    p resource.name      
  end  

  def edit_link
    p link_to "edit", edit_resource_path      
  end  

  def associations_content
    self.class.has_manys.each do |name, has_many|
      div do
        h2 name
        table do
          thead do
            has_many.columns.each do |column|
              th { text column.name }
            end
          end
          tbody do
            resource.send(name).each do |item|              
              tr class: cycle(:odd, :even) do
                has_many.columns.each do |column|
                  td { column.content_for(self, item) }
                end                
              end
            end
          end
        end
      end
    end
  end
end