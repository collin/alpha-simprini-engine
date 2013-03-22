class Views::Resources::Edit < Views::Resources::Form
  def body_content
    back_link
    form_for resource, url: resource_path, &form_block
  end
end