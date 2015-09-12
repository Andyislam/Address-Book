class WelcomeController < ApplicationController
  require 'net/http'

  def index
  	@current_contacts = Contact.where(:user_id => current_user.id).to_a

  	if current_user.provider == 'google_oauth2'
	    @g_contacts =  get_contacts()
	    sync_contact(@g_contacts, @current_contacts)
	end

	@current_contacts = Contact.where(:user_id => current_user.id).sort_by &:name
  end

  def get_contacts ()
  	@token = Token.where(:user_id => current_user.id).last
  	@access = @token.access_token
  	uri = URI.parse("https://www.google.com/m8/feeds/contacts/default/full?oauth_token="+@access.to_s+"&max-results=50000&alt=json")
  	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
  	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  	request = Net::HTTP::Get.new(uri.request_uri)
	response = http.request(request)
	contacts = ActiveSupport::JSON.decode(response.body)

	###needs error trapping for expired token
	contact_array = []
	contacts['feed']['entry'].each_with_index do |contact,index|
	  	c ={}
        name = contact['title']['$t']
        	if name != ''
			  	c['name'] = name
			  	c['email_array'] =[]
		        contact['gd$email'].to_a.each do |email|
		          e = {}
		          if email['rel']
			        	type =  email['rel'].split('#')
			        
			        	e['type'] =  type[1]
			
			        else
			        	e['type'] =  'other'        	
			        end
		          e['email_address'] = email['address']
		          c['email_array'] << e
		        end
		        c['phone_array'] = []
		        contact['gd$phoneNumber'].to_a.each do |phoneNumber|
		        	number = {}
		        	if phoneNumber['rel']
			        	type =  phoneNumber['rel'].split('#')
			        
			        	number['type'] =  type[1]
			
			        else
			        	number['type'] =  'mobile'        	
			        end
		          number['tel'] = phoneNumber['$t']
		          c['phone_array'] << number
		        end
		        contact_array << c
		    end
    end  
  	return contact_array
  end

  def sync_contact(g_contacts, current_contacts)
 	
  	g_contacts.each do |gcontact|
  		contact = current_contacts.select{|c| c.name == gcontact['name']}

  		if contact == []
  			newContact = Contact.new
  			sync = true
  		else
  			newContact = Contact.where(:id => contact.map { |x| x[:id] }).first
  			if newContact.exclude_from_sync == true
  				sync = false
  			else 
  				sync = true
  			end
  		end

  		if sync == true
  			newContact.name = gcontact['name']
  			
  			gcontact['phone_array'].each do |p|
  				sync_detail('Phone', p['type'], p['tel'], newContact.id)
  			end
  			gcontact['email_array'].each do |p|
  				sync_detail('Email', p['type'], p['email_address'], newContact.id)
  			end
  			newContact.google_synced = true
  			newContact.user = current_user
  			newContact.save
  		end 
  	end
  	
  end

  def sync_detail(type, subtype, contact_detail, contact_id)
  	detail = ContactDetail.where(:detail_method=> type, :detail_type => subtype, :contact_id => contact_id).first
  	if detail
		detail.detail = contact_detail
		detail.save
	else
		detail = ContactDetail.new
		detail.contact_id = contact_id
		detail.detail_method = type
		detail.detail_type =  subtype
		detail.detail = contact_detail
		detail.save
	end

  end
end
