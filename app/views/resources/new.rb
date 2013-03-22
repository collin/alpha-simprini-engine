class Views::Resources::New < Views::Resources::Form
  def body_content
    back_link
    form_for resource, url: collection_path, &form_block
  end
end