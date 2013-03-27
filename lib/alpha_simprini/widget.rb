# coding: utf-8
class AlphaSimprini::Widget < Erector::Widget
  def check_mark value
    span (value ? "✓" : "✗"), class: value ? 'yes' : 'no'
  end
end