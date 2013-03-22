class Views::Resources::ShowField < Erector::Widget
  def content
    dt @name.to_s.titleize + ":"
    if @renderer
      dd { instance_exec @resource, &@renderer }
    else
      dd { display(@resource.send(@name)) }
    end
  end

  def display(item)
    send(:"display_#{item.class.name.underscore}", item)
  end

  def display_string(string)
    text string
  end

  def display_fixnum(number)
    text number
  end

  def display_money(money)
    text money.symbol + money.to_s
  end
end