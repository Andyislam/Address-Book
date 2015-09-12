class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.where(:user_id => current_user.id).sort_by &:name
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully deleted.' }
      format.json { head :no_content }
    end
  end


  #custom create/update method
  def update_contact
    detail_array = params[:detail_array].split(',')
    err = []
    if detail_array.size == 0 
      e = {}
      e["error"] = "Please enter contact details"
      err << e
    end
    if params[:name] == ""
      e = {}
      e["error"] = "please enter contact name"
      err << e
    end
    formatted_detail_array = []
    detail_array.each do |detail|
      formatted_detail = {}
      d = detail.split('/')
      d.each do |item|
        i = item.split(':')
        case i[0]
          when 'id'
            formatted_detail['item'] = i[1]
          when "detail_method"
            formatted_detail['method'] = i[1]
          when "detail_type"
            formatted_detail['type'] = i[1]
          when 'detail'
            formatted_detail['item_details'] = i[1]
            if formatted_detail['item_details'] == ' '
              e = {}
              e["error"] = "Please enter a phone number or email for every contact detail item"
              err << e
            end
          end
      end
      formatted_detail_array << formatted_detail
    end

    if err.length > 0
      puts "ERRORS PRESENT"
    else
      if params[:record] == "new"
        @contact = Contact.new
      else 
        @contact = Contact.where(:id => params[:record]).first
      end
      @contact.name = params[:name]
      @contact.exclude_from_sync = params[:exclude_from_sync]
      @contact.user = current_user
      @contact.save

      saved_ids = []
      formatted_detail_array.each do |detail|
        if detail['item'].include? "new"
          cd = ContactDetail.new
        else
          cd = ContactDetail.where(:id => detail['item']).first
        end
        cd.contact_id = @contact.id
        cd.detail_method = detail['method']
        cd.detail_type =  detail['type']
        cd.detail = detail['item_details']
        cd.save
        saved_ids << cd.id
      end

      ContactDetail.where("id NOT IN (?) AND contact_id == ?", saved_ids, @contact.id).destroy_all


      # @deleted = ContactDetail.where.not(id: @saved_ids, contact_id: @contact.id)

      # @dlist.each do |d|

      #     puts "==========#{d.id}"

      # end

      # ContactDetail.where(:contact_id => @contact.id).each do |c|
      #   .select {|v| v["single-key"]["object-identifier"] > 3}
      #   test = formatted_detail_array.where.not(detail['method'] => c.detail_method)
      # end




    end

    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params[:contact]
    end
end
