require 'iconv'

module ApplicationHelper

#def form_field(object,field,flabel,example,val)
    #model_name = eval(object.class.model_name)
	#html = ""
	#html << "<div class=\"param_group\">"
	#if not object.errors[field.to_sym].empty?
		#html << "<div class=\"fieldWithErrors\">"

	#end

	#html << "<label class=\"label\">"
	#flabel.nil? ? html << model_name.human_attribute_name(field) : html << t(flabel.to_sym)
	#html << "</label>"

	#if not object.errors[field.to_sym].empty?
		#html << "<span class=\"error\"> "
		#html << object.errors[field.to_sym].to_s
		#html << "</span>"
		#html << "</div>"
	#end
	#html << "<input id=\""
	#html << object.class.name.downcase+"_"+field
	#html << "\""
	#html << " name=\"#{object.class.name.downcase}[#{field}]\""
	#html << " type=\"text\" class=\"text_field\" value=\""
    #value =  val || object.instance_eval(field) || ""
	#html << value
	#html << "\"/>"
	#html << "<span class=\"description\">"
	#html << t(:example,:scope=>:common)
	#html << ": "
	#html << example
	#html << "</span>"
	#html << "</div>"

#end

#def show_param_view(object,field,value)
    #model_name = eval(object.class.model_name)
    #html = ""
    #html << "<div class=\"group clearfix\">"
    #html << "<label class=\"label\">#{model_name.human_attribute_name(field)}: </label>"
    #html << value
    #html << "</div>"
    #html
#end

#def area_field(object,field,flabel,example,val,cols,rows)
    #model_name = eval(object.class.model_name)
    #html = ""
    #html << "<div class=\"group\">"

    #if not object.errors[field.to_sym].empty?
        #html << "<div class=\"fieldWithErrors\">"
    #end

    #html << "<label class=\"label\">"
    #flabel.nil? ? html << model_name.human_attribute_name(field) : html << t(flabel.to_sym)
    #html << "</label>"

    #if not object.errors[field.to_sym].empty?
        #html << "<span class=\"error\">"
        #html << object.errors[field.to_sym].to_s
        #html << "</span>"
        #html << "</div>"
    #end

    #name = object.class.name.downcase + '[' + field + ']'
    #id = object.class.name.downcase+"_"+field
    #value = val || object.instance_eval(field) || ""
    #html << "<textarea id=\"#{id}\" name=\"#{name}\" class=\"text_area\" cols=\"#{cols}\" rows=\"#{rows}\">#{value}</textarea>"

    #desc = t(:example,:scope=>:common) + ": " + example
    #html << "<span class=\"description\">#{desc}</span>"

    #html << "</div>"
#end

#def form_button(text,image)
	#html = ""
	#html << "<div class=\"group\">"
	#html << "<button class=\"button\" type=\"submit\">"
	#html << "<img src=\""
	#html << current_theme_image_path(image)
	#html << "\" alt=\""
	#html << t(text.to_sym)
	#html << "\" />"
	#html << t(text.to_sym)
	#html << "</button></div>"
#end

#def single_action(text,scope,image)
	#html = ""
	#html << "<div class=\"actiongroup clearfix\">"
	#html << "<button class=\"button\" name=\"#{text}\" type=\"submit\">"
	#html << "<img src=\""
	#html << current_theme_image_path(image)
	#html << "\" alt=\""
	#html << t(text.to_sym, :scope => scope.to_sym)
	#html << "\" />"
	#html << t(text.to_sym, :scope => scope.to_sym)
	#html << "</button></div>"
#end

#def single_action_onclick(text,scope,image,onclick)
	#html = ""
	#html << "<div class=\"actiongroup clearfix\">"
    #html << "<button class=\"button\" type=\"submit\" onclick=\"window.location='"
    #html << onclick
    #html << "'\">"
	#html << "<img src=\""
	#html << current_theme_image_path(image)
	#html << "\" alt=\""
	#html << t(text.to_sym, :scope => scope.to_sym)
	#html << "\" />"
	#html << t(text.to_sym, :scope => scope.to_sym)
	#html << "</button>"
	#html << "</div>"
#end

#def group_action(buttons)
    #html =  ""
	#html << "<div class=\"actiongroup clearfix\">"
	#buttons.each do |b|
        #html << "<button class=\"button\" type=\"submit\" name=\"#{b[:text]}\">"
        #html << "<img src=\""
        #html << current_theme_image_path(b[:image])
        #html << "\" alt=\""
        #html << t(b[:text].to_sym,:scope=>b[:scope].to_sym)
        #html << "\" />"
        #html << t(b[:text].to_sym,:scope=>b[:scope].to_sym)
        #html << "</button> "
	#end
	#html << "</div>"
#end

#def group_action_text(buttons,text)
    #html =  ""
	#html << "<div class=\"group\">"
	#buttons.each do |b|
        #html << "<button class=\"button\" type=\"submit\" name=\"#{b[:text]}\">"
        #html << "<img src=\""
        #html << current_theme_image_path(b[:image])
        #html << "\" alt=\""
        #html << t(b[:text].to_sym,:scope=>b[:scope].to_sym)
        #html << "\" />"
        #html << t(b[:text].to_sym,:scope=>b[:scope].to_sym)
        #html << "</button> "
	#end
	#html << text
	#html << "</div>"
#end

#def form_buttons(buttons)
	#html = ""
	#html << "<div class=\"group\">"

	#buttons.each do |b|
	#html << "<button class=\"button\" type=\"submit\" name=\"#{b[:text]}\">"
	#html << "<img src=\""
	#html << current_theme_image_path(b[:image])
	#html << "\" alt=\""
	#html << t(b[:text].to_sym)
	#html << "\" />"
	#html << t(b[:text].to_sym)
	#html << "</button> "
	#end

	#html << "</div>"
#end

#def form_button_value(text,image,onclick)
	#html = ""
	#html << "<div class=\"group\">"
	#html << "<button class=\"button\" type=\"submit\" onclick=\"window.location='"
	#html << onclick
	#html << "'\">"
	#html << "<img src=\""
	#html << current_theme_image_path(image)
	#html << "\" alt=\""
	#html << text
	#html << "\" />"
	#html << t(text.to_sym)
	#html << "</button></div>"
#end

#def simple_input_field(name,id,label,value)
    #html = ""
    #html << "<div class=\"param_group\">"
    #html << "<label class=\"label\">#{label}</label>"
    #html << "<input name=\"#{name}[#{id}]\" id=\"#{name}_#{id} class=\"text_field\" type=\"text\" value=\"#{value}\">"
    #html << "</div>"
#end

#def select_field(name,object,label,blank)
    #html = ""
    #html << "<div class=\"group\">"
    #html << "<label class=\"label\">#{label}</label>"
    #html << select(name, name, object.all.collect {|p| [ p.name, p.id ] }, { :include_blank => (blank == true ? true : false)})
    #html << "</div>"
#end

#def select_field_table(object,field,table_choices,choice,blank)
    #model_name = eval(object.class.model_name)
    #html = ""
    #html << "<div class=\"param_group\">"
    #html << "<label class=\"label\">#{model_name.human_attribute_name(field)}</label>"
    #html << select(object.class.to_s.downcase, field, options_for_select(table_choices,choice), {:include_blank => blank})
    #html << "</div>"
#end

#def select_field_table_t(object,field,table_choices,choice,blank)
    #model_name = eval(object.class.model_name)
    #html = ""
    #html << "<div class=\"param_group\">"
    #html << "<label class=\"label\">#{model_name.human_attribute_name(field)}</label>"
    #t = []
    #table_choices.each do |c|
        #t << [t(c.to_sym,:scope=>:prefs),c.to_s]
    #end
    #html << select(object.class.to_s.downcase, field, options_for_select(t,choice), {:include_blank => blank})
    #html << "</div>"
#end

##def form_simle_field(name,label,value)
##    html = ""
##    html << "<div class=\"group\">"
##    html << "<label class=\"label\">#{label}</label>"
##    html << "<input class=\"text_field\" type=\"text\" value=\"#{value}\">"
##    html << "</div>"
##end

##def nav_to_folders
##    link_to( t(:folders,:scope=>:folder), :controller=>:folders, :action=>:index )
##end
##
##def nav_to_messages
##    link_to( t(:messages,:scope=>:message), :controller=>:messages, :action=>:index )
##end
##
##def nav_to_compose
##    link_to( t(:compose,:scope=>:compose), :controller=>:messages, :action=>:compose )
##end
##
##def nav_to_contacts
##    link_to( t(:contacts,:scope=>:contact), contacts_path )
##end
##
##def nav_to_prefs
##    link_to( t(:prefs,:scope=>:prefs), prefs_look_path )
##end

#def single_navigation(label,scope)
    #s = ""
    #s += "<ul>"
    #s += "<li class=\"first active\">#{link_to(t(label,:scope=>scope),'#')}</li>"
    #s += "<li class=\"last\">&nbsp;</li>"
    #s += "</ul>"
#end

#def main_navigation(active)
    #instance_variable_set("@#{active}", "active")
    #s = ""
    #s += "<ul>"
    #s += "<li class=\"first #{@messages_tab}\">#{link_to( t(:messages,:scope=>:message), messages_path )}</li>"
    #s += "<li class=\"#{@compose_tab}\">#{link_to( t(:compose,:scope=>:compose), compose_path )}</li>"
    #s += "<li class=\"#{@folders_tab}\">#{link_to( t(:folders,:scope=>:folder), folders_path )}</li>"
    #s += "<li class=\"#{@contacts_tab}\">#{link_to( t(:contacts,:scope=>:contact), contacts_path )}</li>"
    #s += "<li class=\"#{@prefs_tab}\">#{link_to( t(:prefs,:scope=>:prefs), prefs_look_path )}</li>"
    #s += "<li class=\"last #{@links_tab}\">#{link_to( t(:links,:scope=>:link), links_path )}</li>"
    #s += "</ul>"
#end

#def prefs_navigation(active)
    #instance_variable_set("@#{active}", "active")
    #s = ""
    #s += "<ul>"
    #s += "<li class=\"first #{@look_tab}\">#{link_to( t(:look,:scope=>:prefs), prefs_look_path )}</li>"
    #s += "<li class=\"#{@identity_tab}\">#{link_to( t(:identity,:scope=>:prefs), prefs_identity_path )}</li>"
    #s += "<li class=\"last #{@servers_tab}\">#{link_to( t(:servers,:scope=>:prefs), prefs_servers_path )}</li>"
    #s += "</ul>"
#end

#def multi_select(id, name, objects, selected_objects, label, value,joiner,content = {})
  #options = ""
  #objects.each do |o|
    #selected = selected_objects.include?(o) ? " selected=\"selected\"" : ""
    #option_value = escape_once(o.send(value))
    #text = [option_value]
    #unless content[:text].nil?
      #text = []
      #content[:text].each do |t|
        #text << o.send(t)
      #end
      #text = text.join(joiner)
    #end
    #text.gsub!(/^\./,'')
    #bracket = []
    #unless content[:bracket].nil?
      #content[:bracket].each do |b|
        #bracket << o.send(b)
      #end
      #bracket = bracket.join(joiner)
    #end
    #option_content = bracket.empty? ? "#{text}" : "#{text} (#{bracket})"
    #options << "<option value=\"#{option_value}\"#{selected}>&nbsp;&nbsp;#{option_content}&nbsp;&nbsp;</option>\n"
  #end
  #"<div class=\"param_group\"><label class=\"label\">#{label}</label><select multiple=\"multiple\" size=10 id=\"#{id}\" name=\"#{name}\">\n#{options}</select></div>"
#end

#def force_charset(text)
    #begin
        #Iconv.iconv("UTF-8",$defaults["msg_unknown_charset"],text)
    #rescue
        #text
    #end
#end

#def content_for_sidebar
    #s = render :partial => 'sidebar/logo'
    #s += render :partial => 'folders/list'
    #s += render :partial => 'sidebar/calendar_view'
    #s += render :partial => 'internal/version'
    #s
#end

#def boolean_answer(answer)
	#answer == true ? t(:true_answer,:scope=>:common) : t(:false_answer,:scope=>:common)
#end

end
