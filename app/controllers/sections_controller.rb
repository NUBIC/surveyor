class SectionsController < ApplicationController
  
  # GET /sections
   # GET /sections.xml
   def index
     @sections = SurveySection.find(:all)

     respond_to do |format|
       format.html # index.html.erb
       format.xml  { render :xml => @sections }
     end
   end

   # GET /sections/1
   # GET /sections/1.xml
   def show
     @section = SurveySection.find(params[:id])

     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @section.to_xml(:include => :questions) }
     end
   end

   # GET /sections/new
   # GET /sections/new.xml
   def new
     @section = SurveySection.new

     respond_to do |format|
       format.html # new.html.erb
       format.xml  { render :xml => @section }
     end
   end

   # GET /sections/1/edit
   def edit
     @section = SurveySection.find(params[:id])
   end

   # POST /sections
   # POST /sections.xml
   def create
     @section = SurveySection.new(params[:section])

     respond_to do |format|
       if @section.save
         flash[:notice] = 'Section was successfully created.'
         format.html { redirect_to(@section) }
         format.xml  { render :xml => @section, :status => :created, :location => @section }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
       end
     end
   end

   # PUT /sections/1
   # PUT /sections/1.xml
   def update
     @section = SurveySection.find(params[:id])

     respond_to do |format|
       if @section.update_attributes(params[:section])
         flash[:notice] = 'Section was successfully updated.'
         format.html { redirect_to(@section) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
       end
     end
   end

   # DELETE /sections/1
   # DELETE /sections/1.xml
   def destroy
     @section = SurveySection.find(params[:id])
     @section.destroy

     respond_to do |format|
       format.html { redirect_to(sections_url) }
       format.xml  { head :ok }
     end
   end
  
end
