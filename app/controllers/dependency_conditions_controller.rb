class DependencyConditionsController < ApplicationController
  
  # GET /dependency_conditions
   # GET /dependency_conditions.xml
   def index
     @dependency_conditions = DependencyCondition.find(:all)

     respond_to do |format|
       format.html # index.html.erb
       format.xml  { render :xml => @dependency_conditions }
     end
   end

   # GET /dependency_conditions/1
   # GET /dependency_conditions/1.xml
   def show
     @dependency_condition = DependencyCondition.find(params[:id])

     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @dependency_condition }
     end
   end

   # GET /dependency_conditions/new
   # GET /dependency_conditions/new.xml
   def new
     @dependency_condition = DependencyCondition.new

     respond_to do |format|
       format.html # new.html.erb
       format.xml  { render :xml => @dependency_condition }
     end
   end

   # GET /dependency_conditions/1/edit
   def edit
     @dependency_condition = DependencyCondition.find(params[:id])
   end

   # POST /dependency_conditions
   # POST /dependency_conditions.xml
   def create
     @dependency_condition = DependencyCondition.new(params[:dependency_condition])

     respond_to do |format|
       if @dependency_condition.save
         flash[:notice] = 'DependencyCondition was successfully created.'
         format.html { redirect_to(@dependency_condition) }
         format.xml  { render :xml => @dependency_condition, :status => :created, :location => @dependency_condition }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @dependency_condition.errors, :status => :unprocessable_entity }
       end
     end
   end

   # PUT /dependency_conditions/1
   # PUT /dependency_conditions/1.xml
   def update
     @dependency_condition = DependencyCondition.find(params[:id])

     respond_to do |format|
       if @dependency_condition.update_attributes(params[:dependency_condition])
         flash[:notice] = 'DependencyCondition was successfully updated.'
         format.html { redirect_to(@dependency_condition) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @dependency_condition.errors, :status => :unprocessable_entity }
       end
     end
   end

   # DELETE /dependency_conditions/1
   # DELETE /dependency_conditions/1.xml
   def destroy
     @dependency_condition = DependencyCondition.find(params[:id])
     @dependency_condition.destroy

     respond_to do |format|
       format.html { redirect_to(dependency_conditions_url) }
       format.xml  { head :ok }
     end
   end
  
end
