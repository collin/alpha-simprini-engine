# coding: utf-8
module Views::Listing
  extend ActiveSupport::Concern
  include Kaminari::ActionViewExtension

  included do
    class_attribute :actions
    class_attribute :admin
    class_attribute :iterator_method
    class_attribute :header_text
    self.iterator_method = :each
    self.actions = [:view, :edit, :delete]
  end

  module ClassMethods
    def header(text)
      self.header_text = text
    end

    def create(value=nil, &block)
      @create = value unless value.nil?
      @create = block if block_given?
      if defined? @create
        @create
      else
        nil
      end
    end

    def content_fields
      @content_fields ||= []
    end

    def field(name, options={}, &content)
      content_fields.push [name, options, content]
    end

    def after_row(&block)
      @after_row_block = block
    end

    def after_table(&block)
      @after_table_block = block
    end

    def after_table_block
      @after_table_block
    end

    def after_row_block
      @after_row_block
    end

    def no_actions!
      self.actions = []
    end

    def iterator(method)
      self.iterator_method = method
    end
  end

  def content_fields
    self.class.content_fields
  end

  def item_class
    collection.name.dasherize.downcase
  end

  def blank_slate
    text "Blank Slate" unless collection.any?
  end

  def create?
    create = self.class.create
    if create == true
      true
    elsif create == false
      false
    elsif create.respond_to?(:call)
      instance_eval &create
    elsif create.nil?
      not(no_actions)
    end
  end

  # SAVEME: list based listing
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

  def table_listing
    link_to_create      
    blank_slate
    if collection.any?
      table class: collection_class do
        if respond_to?(:any_filters?) and any_filters?
          p class:'lead' do
            text "found #{pluralize(collection.limit(nil).count, resource_name.titlecase)} that match your filters:"
          end
        end
        table_header
        each_item &method(:row)
        if after_table = self.class.after_table_block
          instance_exec &after_table
        end
      end
      pagination
    end    
  end
  alias listing table_listing

  def link_to_create
    return unless create?
    link_to "Add #{resource_name.titlecase.indefinitize}", new_resource_path, class:'new'
  end

  def each_item(&block)
    collection.send(iterator, &block)
  end

  def collection_name
    if collection.is_a? Array
      header_text || ""
    else
      collection.name
    end
  end

  def iterator
    self.class.iterator_method
  end

  def pagination
    return unless collection.respond_to?(:current_page)
    nav class:'pagination' do
      ol do
        paginate(collection, theme:'twitter-bootstrap') 
      end
    end
  end
  
  def no_actions
    self.class.actions.empty?
  end

  def action?(action)
    self.class.actions.include?(action.to_sym)
  end

  def delete?
    action? :delete
  end

  def edit?
    action?(:edit) && defined?(component.view_module::Edit)
  end

  def view?
    action?(:view) && defined?(component.view_module::Show)
  end

  def links_for_item(item)
    return if no_actions && self.class.action_items.none?
    span do
      action_links(item)
    end
  end

  def _resource_path(item)
    resource_path(item)
  end

  def _edit_resource_path(item)
    edit_resource_path(item)
  end

  def action_links(item)
    unless no_actions
      view? and link_to "View", _resource_path(item)
      edit? and link_to "Edit", _edit_resource_path(item)
      delete? and link_to "Delete", _resource_path(item), class:'destructive', method: 'delete', confirm: 'Are you sure you want to delete this?', remote:true
    end
    self.class.action_items.each do |(name, action, options, block)|
      if !(action || block)
        raise "Action Links MUST specify either an action or a block."
      end

      if action
        link_to name, url, {method: 'put'}.reverse_merge(options)
      else
        instance_exec item, &block        
      end
    end
  end

  def collection_class
    if self.class.header_text
      [self.class.header_text.downcase.sub(' ', '-'), :records]
    else
      [collection_name.pluralize.dasherize.downcase, :records]
    end
  end

  def header_text
    self.class.header_text or collection.name.pluralize
  end

  def list_header
    content_fields.each do |(field, _)|
      span field.to_s.titlecase
    end
  end  

  def table_header
    thead do
      # tr do
      #   th "Total"
      #   content_fields.each_with_index do |(field, block), index|
      #     next if index.zero?
      #     if field.sum?
      #       th number_to_currency(field.sum_value)
      #     else
      #       th
      #     end
      #   end
      # end
      tr do
        content_fields.each_with_index do |(field, options, block), index|
          th do
            text field.to_s.titlecase
          end
        end

        th "Action", class:'actions'
      end
    end
  end

  def row(item)
    tr do
      content_fields.each do |(field, options, block)|
        td do
          if block
            instance_exec item, &block
          else
            text item.send(field).presence || check_mark(false)
          end
        end
      end  

      td(class:'actions') { links_for_item item }    
    end

    if after_row = self.class.after_row_block
      instance_exec item, &after_row
    end
  end

  def list_representation(item)
    content_fields.each do |(field, block)|
      span do
        if block
          instance_exec item, &block
        else
          text item.send(field).presence || check_mark(false)
        end        
      end
    end

    links_for_item(item)
  end
end