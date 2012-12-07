class PagesController < ApplicationController

	layout 'admin'
  	
  	before_filter :confirm_logged_in
  	
	# default behavior
	def index
		list # sets the instance variables
		# would try to render index
		render('list')
	end

	def list
		# get Pages into instance variable, then available to template
		@pages = Page.order("position ASC")
	end
	
	def show
		@page = Page.find(params[:id])
	end

	def new
		@page = Page.new
		@page_count = Page.count + 1
		@subjects = Subject.all.collect{|s| [s.name, s.id]}
	end
	
	def create
		# 1 instantiate
		@page = Page.new(params[:page])
		# 2 save
		if @page.save
			# 3 if save succeeds
			flash[:notice] = "Page created successfully"
			redirect_to(:action => 'list')
		else 
			# if save fails, render the new template
			# make sure @page is instance variable, because the new template is looking for it
			@page_count = Page.count + 1
			render('new')
		end
		# in either case we don't need a template for create
	end
	
	def edit
		@page = Page.find(params[:id])
		@page_count = Page.count
		@subjects = Subject.all.collect{|s| [s.name, s.id]}
	end
	
	def update
		@page = Page.find(params[:id])
		if @page.update_attributes(params[:page])
			flash[:notice] = "Page updated successfully"
			redirect_to(:action => 'show', :id => @page.id)
		else
			@page_count = Page.count
			render('edit')
		end
		# in either case we don't need a template for create
	end
	
	def delete
		@page = Page.find(params[:id])
	end
	
	def destroy
		page.find(params[:id]).destroy
		flash[:notice] = "Page destroyed successfully"
		redirect_to(:action => 'list')
	end
end
