class SectionsController < ApplicationController

	layout 'admin'
	
	before_filter :confirm_logged_in
	
	# default behavior
	def index
		list # sets the instance variables
		# would try to render index
		render('list')
	end

	def list
		# get Sections into instance variable, then available to template
		@sections = Section.order("position ASC")
	end
	
	def show
		@section = Section.find(params[:id])
	end

	def new
		@section = Section.new
		@section_count = Section.count + 1
		@pages = Page.all.collect{|s| [ s.name, s.id ]}
	end
	
	def create
		# 1 instantiate
		@section = Section.new(params[:section])
		# 2 save
		if @section.save
			# 3 if save succeeds
			flash[:notice] = "Section created successfully"
			redirect_to(:action => 'list')
		else 
			# if save fails, render the new template
			# make sure @section is instance variable, because the new template is looking for it
			@section_count = Section.count + 1
			render('new')
		end
		# in either case we don't need a template for create
	end
	
	def edit
		@section_count = Section.count
		@section = Section.find(params[:id])
		@pages = Page.all.collect{|s| [ s.name, s.id ]}
	end
	
	def update
		@section = Section.find(params[:id])
		if @section.update_attributes(params[:section])
			flash[:notice] = "Section updated successfully"
			redirect_to(:action => 'show', :id => @section.id)
		else 
			@section_count = Section.count
			render('edit')
		end
		# in either case we don't need a template for create
	end
	
	def delete
		@section = Section.find(params[:id])
	end
	
	def destroy
		section.find(params[:id]).destroy
		flash[:notice] = "Section destroyed successfully"
		redirect_to(:action => 'list')
	end
end
