class Views::Resources::ShowHasMany < Erector::Widget
  include Views::Listing
  no_actions!

  attr_accessor :collection


  def content
    h1 header
    listing
  end

end