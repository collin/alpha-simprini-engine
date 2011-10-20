class Views::Resources::Form < Views::Resources::Base
  def body_content
    form do |form|
      fields(form)
      buttons(form)
    end
  end
  
  def fields(form)
    available_fields.each do |key, value|
      input(form, key, :text_field)
    end
  end

  def buttons(form)
    div class: 'buttons' do
      form.submit
    end    
  end

  def available_fields
    resource.fields.reject do |key, value|
      key.starts_with?("_")
    end
  end
end
