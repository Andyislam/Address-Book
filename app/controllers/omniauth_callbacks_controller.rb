class OmniauthCallbacksController < Devise::OmniauthCallbacksController   
	def google_oauth2
		@user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
		@auth = request.env['omniauth.auth']['credentials']
		Token.create(
	      access_token: @auth['token'],
	      refresh_token: @auth['refresh_token'],
	      user_id: @user.id,
	      expires_at: Time.at(@auth['expires_at']).to_datetime)
		  

		if @user.persisted?
		  flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
		  sign_in_and_redirect @user, :event => :authentication
		else
		  session["devise.google_data"] = request.env["omniauth.auth"]
		  redirect_to new_user_registration_url
		end
	end
end