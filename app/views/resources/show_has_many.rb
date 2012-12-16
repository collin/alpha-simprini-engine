class Views::Resources::ShowHasMany < Erector::Widget
  include Views::Listing
  no_actions!

  attr_accessor :collection

  def content
    listing
  end
end