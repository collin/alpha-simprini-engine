class Views::Resources::ShowHasMany
  class Column
    attr_accessor :name
    def initialize(name, &content_for_block)
      @name = name
      @content_for_block = content_for_block
    end
    
    def content_for(context, item)
      content = if @content_for_block
        context.instance_exec(item, &@content_for_block)
      else
        item.send(name)
      end
      
      context.text content if content.is_a?(String)
    end
  end
  attr_accessor :columns
  def initialize(&config)
    @columns = []
    instance_eval(&config)
  end
  
  def column(name, &block)
    self.columns << Column.new(name, &block)
  end
end