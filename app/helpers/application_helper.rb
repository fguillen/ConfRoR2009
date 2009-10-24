# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def title(page_title)
    content_for(:title) { page_title }
  end

  def menu_to(name, options = {}, html_options = {}, &block)
    content = link_to("<span>#{name}</span>", options, html_options, &block)
    if current_page?(options)
      "<li class=\"current\">#{content}</li>"
    else
      "<li>#{content}</li>"
    end
  end
  
  def label(object_name, method, text = nil, options = {})
    if options[:required]
      "<label for=\"#{method}\">#{text} <span class=\"required\">*</span></label>"
    else
      "<label for=\"#{method}\">#{text}</label>"
    end
  end
  
  def times_array( hour_ini = '00', hour_end = '24' )
    times = []
    (hour_ini..hour_end).each do |hh|
      ['00','05','10','15','20','25','30','35','40','45','50','55'].each do |mm|
        times << "#{hh}:#{mm}" 
      end
    end

    return times
  end

  def base_url
    request.protocol + request.host_with_port
  end
  
  # render an url or a simple text or a link
  # depending of the presence of the arguments
  def web_render( web_name, web_url )
    return link_to( web_name, web_url )   if !web_name.empty? && !web_url.empty?
    return link_to( web_url, web_url )    if web_name.empty? && !web_url.empty?
    return web_name                       if !web_name.empty? && web_url.empty?
  end
  
  
  def admin_or_current_user?(user)
    return (logged_in? && (admin? || user == current_user))
  end
  
  def users_to_csv( users )
    out = ""
    
    users.each_with_index do |user,index|
      out += "#{"%03d" % index}, #{"%03d" % user.id}, #{user.name}"
      out += ", #{user.email}"  if admin?
      out += "\n"
    end
    
    return out
  end
  
  def papers_to_csv( papers )
    out = "index,id,title,speakers,status,permalink,description\n"
    
    papers.each_with_index do |paper,index|
      out += "#{"%03d" % index}"
      out += ",#{paper.id}"
      out += ",\"#{paper.title}\""
      out += ",\"#{paper.speaking_users.map{ |e| e.name }.to_sentence}\""
      out += ",#{paper.status}"
      out += ",#{paper.permalink}"
      out += ",\"#{paper.description}\""
      out += "\n"
    end
    
    return out
  end
  
  def paginate(collection, will_paginate_options = {})
    will_default = {:inner_window => 1, :previous_label => '&laquo; ' + t('views.pagination.previous'), :next_label => t('views.pagination.next') + ' &raquo;'}
    will_paginate_options = will_default.merge(will_paginate_options)
    
    will_paginate(collection, will_paginate_options)
  end
  
  def valoration_labels
    [t('views.papers.show.valorations.very_bad'), t('views.papers.show.valorations.poor'), t('views.papers.show.valorations.average'), t('views.papers.show.valorations.good'), t('views.papers.show.valorations.excelent')]
  end
  
end
