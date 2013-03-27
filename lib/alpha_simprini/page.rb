# coding: utf-8
require "erector"
module AlphaSimprini
  class Page < AlphaSimprini::Widget
    class_attribute :scripts
    class_attribute :stylesheets

    self.scripts     = []
    self.stylesheets = []

    def self.script script
      self.scripts << script
    end

    def self.stylesheet stylesheet
      self.stylesheets << stylesheet
    end

    def content
      text :doctype_html
      html(html_attrs) do
        head do
          csrf_meta_tag
          title :application_title
          assets
        end
        body do
          section id:'notices' do
            notices            
          end

          header do
            header_content            
          end
          
          section id:'content' do
            body_content
          end

          footer do
            footer_content            
          end
        end
      end
    end
  
    def html_attrs
      {}
    end

    def notices
      flash.notice and p class: "notice" do text flash.notice end
      flash.alert and p class: "alert" do text flash.alert end
    end
  
    def assets
      stylesheet_link_tag *stylesheets
      javascript_include_tag *scripts
    end
  
    def copy key
      p t(key)
    end
  
    def text(value)
      if value.is_a?(Symbol)
        output << h(t(value))
      else
        super
      end
    end
  
    def header_content
      
    end

    def body_content
      copy :blank
    end

    def footer_content
      
    end
  end
end
