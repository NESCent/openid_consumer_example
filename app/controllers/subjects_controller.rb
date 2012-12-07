class SubjectsController < ApplicationController

	layout 'admin'
	
	before_filter :confirm_logged_in
	
	# default behavior
	def index
		list # sets the instance variables
		# would try to render index
		render('list')
	end

	def list
		# get subjects into instance variable, then available to template
		@subjects = Subject.order("position ASC")
	end
	
	def show
		@subject = Subject.find(params[:id])
	end

	def new
		@subject = Subject.new
		@subject_count = Subject.count + 1
	end
	
	def create
		# 1 instantiate
		@subject = Subject.new(params[:subject])
		# 2 save
		if @subject.save
			# 3 if save succeeds
			flash[:notice] = "Subject created successfully"
			redirect_to(:action => 'list')
		else 
			# if save fails, render the new template
			# make sure @subject is instance variable, because the new template is looking for it
			@subject_count = Subject.count + 1
			render('new')
		end
		# in either case we don't need a template for create
	end
	
	def edit
		@subject = Subject.find(params[:id])
		@subject_count = Subject.count
	end
	
	def update
		@subject = Subject.find(params[:id])
		if @subject.update_attributes(params[:subject])
			flash[:notice] = "Subject updated successfully"
			redirect_to(:action => 'show', :id => @subject.id)
		else
			@subject_count = Subject.count
			render('edit')
		end
		# in either case we don't need a template for create
	end
	
	def delete
		@subject = Subject.find(params[:id])
	end
	
	def destroy
		Subject.find(params[:id]).destroy
		flash[:notice] = "Subject destroyed successfully"
		redirect_to(:action => 'list')
	end
end
