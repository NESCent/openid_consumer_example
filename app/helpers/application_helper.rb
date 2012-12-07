module ApplicationHelper
	# What does this do.
	# takes a boolean and options hash.  options hash has true, true_class, false_false_class
	# boolean is either true or false
	def status_tag(boolean, options={})
		# set up default values for the hash
		options[:true]				||= ''
		options[:true_class]		||= 'status true'
		options[:false]				||= ''
		options[:false_class]		||= 'status false'
		
		if boolean
			# if the passed-in-boolean was true, return a span tag with the class of status true
			content_tag(:span, options[:true], :class => options[:true_class])
		else
			content_tag(:span, options[:false], :class => options[:false_class])
		
		end
	end
	
	def error_messages_for( object )
		render(:partial => 'shared/error_messages', :locals => {:object => object})
	end
end
