class Admin::UsersController < ApplicationController
  
  def search
    case params[:search][:search_type]
      when "email"
        @users = User.find(
          :all, 
          :conditions => ["email LIKE ?", "%#{params[:search][:search_term]}%"]
          ).paginate :per_page => 10, :page => params[:page]
      when "last_name"
        @users = User.find(
          :all, 
          :conditions => ["last_name LIKE ?", "%#{params[:search][:search_term]}%"]
          ).paginate :per_page => 10, :page => params[:page]
      when "full_name"
        first_name, last_name = params[:search][:search_term].split(" ")
        @users = User.find(
          :all, 
          :conditions => ["first_name LIKE ? AND last_name LIKE ?", "%#{first_name}%", "%#{last_name}%"]
          ).paginate :per_page => 10, :page => params[:page]
    end
    
    render :action => :index
    
  end #end method search
  
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @user.role_ids = [1] #new user automatically gets "customer" role
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.role_ids = params[:user][:role_ids]

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(admin_users_path) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @user.role_ids = params[:user][:role_ids]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(admin_users_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
end
