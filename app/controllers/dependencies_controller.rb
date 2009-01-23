class DependenciesController < ApplicationController
  
  # GET /dependencies
   # GET /dependencies.xml
   def index
     @dependencies = Dependency.find(:all)

     respond_to do |format|
       format.html # index.html.erb
       format.xml  { render :xml => @dependencies}
     end
   end

   # GET /dependencies/1
   # GET /dependencies/1.xml
   def show
     @dependency = Dependency.find(params[:id])

     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @dependency, :include => [:dependency_conditions] }
     end
   end

   # GET /dependencies/new
   # GET /dependencies/new.xml
   def new
     @dependency = Dependency.new

     respond_to do |format|
       format.html # new.html.erb
       format.xml  { render :xml => @dependency }
     end
   end

   # GET /dependencies/1/edit
   def edit
     @dependency = Dependency.find(params[:id])
   end

   # POST /dependencies
   # POST /dependencies.xml
   def create
     @dependency = Dependency.new(params[:dependency])

     respond_to do |format|
       if @dependency.save
         flash[:notice] = 'Dependency was successfully created.'
         format.html { redirect_to(@dependency) }
         format.xml  { render :xml => @dependency, :status => :created, :location => @dependency }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @dependency.errors, :status => :unprocessable_entity }
       end
     end
   end

   # PUT /dependencies/1
   # PUT /dependencies/1.xml
   def update
     @dependency = Dependency.find(params[:id])

     respond_to do |format|
       if @dependency.update_attributes(params[:dependency])
         flash[:notice] = 'Dependency was successfully updated.'
         format.html { redirect_to(@dependency) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @dependency.errors, :status => :unprocessable_entity }
       end
     end
   end

   # DELETE /dependencies/1
   # DELETE /dependencies/1.xml
   def destroy
     @dependency = Dependency.find(params[:id])
     @dependency.destroy

     respond_to do |format|
       format.html { redirect_to(dependencies_url) }
       format.xml  { head :ok }
     end
   end
  
end
