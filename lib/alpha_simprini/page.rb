require "erector"
module AlphaSimprini
  class Page < Erector::Widget
    def content
      text :doctype_html
      html do
        head do
          csrf_meta_tag
          title :application_title
          assets
        end
        body do
          notices
          body_content
        end
      end
    end
  
    def notices
      p class: "notice" do text flash.notice end
      p class: "alert" do text flash.alert end
    end
  
    def assets
    end
  
    def copy key
      p t(key)
    end
  
    def text(value)
      if value.is_a? Symbol
        output << h(t(value))
      else
        super
      end
    end
  
    def body_content
      copy :blank
    end
  end
end
