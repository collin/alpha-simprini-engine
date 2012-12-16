module Views::Listing
  extend ActiveSupport::Concern
  include Kaminari::ActionViewExtension

  included do
    class_attribute :no_actions
    class_attribute :admin
  end

  module ClassMethods
    def content_fields
      @content_fields ||= []
    end

    def field(name, &content)
      content_fields.push [name, content]    
    end

    def no_actions!
      self.no_actions = true
    end

    def action_item(name, action, &block)
      self. action_items << [name, action]
    end
  end

  def content_fields
    self.class.content_fields
  end

  def collection_class
    [collection.name.pluralize.dasherize.downcase, :records]
  end

  def item_class
    collection.name.dasherize.downcase
  end

  def blank_slate
    text "Blank Slate"
  end

  # def listing
  #   blank_slate
  #   if collection.any?
  #     ul class: collection_class do
  #       li class: 'header' do
  #         list_header
  #       end
  #       collection.each do |item|
  #         li class: item_class do
  #           list_representation(item)
  #         end
  #       end
  #     end
  #   end    
  # end

  def listing
    blank_slate
    if collection.any?
      paginate collection if collection.respond_to?(:current_page)
      table class: collection_class do
        table_header
        collection.each do |item|
          row(item)
        end
      end
    end    
  end

  
  def no_actions
    self.class.no_actions
  end

  def links_for_item(item)
    return if no_actions
    span do
      action_links(item)
    end
  end

  def action_items
    self.class.action_items
  end

  def action_links(item)
    link_to "View", resource_path(item)
    link_to "Edit", edit_resource_path(item)
    link_to "Delete", resource_path(item), method: 'delete'
    self.action_items.each do |(name, action, block)|
      link_to name, send("#{action}_resource_path", item), method: 'post'
    end
  end
  
  def list_header
    content_fields.each do |(field, _)|
      span field.to_s.titlecase
    end
  end  

  def table_header
    thead do
      tr do
        content_fields.each do |(field, block)|
          td do
            text field.to_s.titlecase
          end
        end

        td { "Actions" }
      end
    end
  end

  def row(item)
    tr do
      content_fields.each do |(field, block)|
        td do
          if block
            instance_exec item, &block
          else
            text item.send(field).presence || "--"
          end
        end
      end  

      td { links_for_item item }    
    end
  end

  def list_representation(item)
    content_fields.each do |(field, block)|
      span do
        if block
          instance_exec item, &block
        else
          text item.send(field).presence || "--"
        end        
      end
    end

    links_for_item(item)
  end
end