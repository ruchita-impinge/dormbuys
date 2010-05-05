class Admin::GiftCardsController < ApplicationController
  
  def search
    
    @gift_cards = GiftCard.find(:all, 
      :conditions => ["giftcard_number LIKE ?", "%#{params[:search][:search_term]}%"]
      ).paginate :per_page => 10, :page => params[:page]
    
    render :action => :index
    
  end #end method search
  
  
  # GET /gift_cards
  # GET /gift_cards.xml
  def index
    @gift_cards = GiftCard.find(:all).paginate :per_page => 10, :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @gift_cards }
    end
  end

  # GET /gift_cards/1
  # GET /gift_cards/1.xml
  def show
    @gift_card = GiftCard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @gift_card }
    end
  end

  # GET /gift_cards/new
  # GET /gift_cards/new.xml
  def new
    @gift_card = GiftCard.new
    @gift_card.expiration_date = Date.today + 1.year
    @gift_card.generate_new_number_and_pin

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @gift_card }
    end
  end

  # GET /gift_cards/1/edit
  def edit
    @gift_card = GiftCard.find(params[:id])
  end

  # POST /gift_cards
  # POST /gift_cards.xml
  def create
    @gift_card = GiftCard.new(params[:gift_card])

    respond_to do |format|
      if @gift_card.save
        flash[:notice] = 'GiftCard was successfully created.'
        format.html { redirect_to(admin_gift_cards_path) }
        format.xml  { render :xml => @gift_card, :status => :created, :location => @gift_card }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @gift_card.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /gift_cards/1
  # PUT /gift_cards/1.xml
  def update
    @gift_card = GiftCard.find(params[:id])

    respond_to do |format|
      if @gift_card.update_attributes(params[:gift_card])
        flash[:notice] = 'GiftCard was successfully updated.'
        format.html { redirect_to(admin_gift_cards_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gift_card.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /gift_cards/1
  # DELETE /gift_cards/1.xml
  def destroy
    @gift_card = GiftCard.find(params[:id])
    @gift_card.destroy

    respond_to do |format|
      format.html { redirect_to(admin_gift_cards_url) }
      format.xml  { head :ok }
    end
  end
end
