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
end
