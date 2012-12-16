class Views::Resources::Form < Views::Resources::Base
  def self.form(&block)
    @form_block = block
  end

  def self.form_block
    @form_block
  end

  def form_block
    self.class.form_block
  end

  def form_for(resource, options={}, &block)
    options[:builder] ||= FormBuilder.wrapping(NestedForm::SimpleBuilder)
    text(helpers.form_for(resource, options) do |f|
      instance_exec(f, &block) if block_given?  
    end << helpers.send(:after_nested_form_callbacks) )
  end
end
