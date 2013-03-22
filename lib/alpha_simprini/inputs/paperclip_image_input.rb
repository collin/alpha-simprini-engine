class SimpleForm::Inputs::PaperclipImageInput < SimpleForm::Inputs::FileInput
  def input
    out = ''.html_safe # the output string we're going to build
    # check if there's an uploaded file (eg: edit mode or form not saved)
    if has_an_image?
      # append preview image to output
      # <%= image_tag @user.avatar.url(:thumb), :class => 'thumbnail', id: 'avatar' %>
      out.safe_concat template.image_tag(object.send(attribute_name).url(:thumbnail), :class => 'thumbnail')
    end
    # append file input. it will work accordingly with your simple_form wrappers
    (out.safe_concat @builder.file_field(attribute_name, input_html_options))
    out
  end

  def has_an_image?
    object.send("#{attribute_name}?")
  end
end