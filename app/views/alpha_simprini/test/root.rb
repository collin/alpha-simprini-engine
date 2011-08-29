class Views::AlphaSimprini::Test::Root < AlphaSimprini::Page
  def assets
    javascript_include_tag "test"
    stylesheet_link_tag "qunit"
  end

  def body_content
    h1 "QUnit", id:'qunit-header'
    h1 id:'qunit-banner'
    h2 id:'qunit-userAgent'
    ol id:'qunit-tests'
  end
end