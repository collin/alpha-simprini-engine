class Views::Resources::Edit < Views::Resources::Base
  def page_title
    "Edit #{resource_name}"
  end
  
  def body_content
    form_for resource, url: resource_url(resource) do |form|
      available_fields.each do |key, value|
        input(form, key, :text_field)
      end
      div class: 'buttons' do
        form.submit
      end
    end
  end
  
  def available_fields
    resource.fields.reject do |key, value|
      key.starts_with?("_")
    end
  end
end