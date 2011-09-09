require 'ezcrypto'

class User < ActiveRecord::Base

    validates_presence_of :first_name,:last_name
	validates_uniqueness_of :email
	has_many :servers, :dependent => :destroy
	has_one :prefs, :dependent => :destroy
	has_many :folders, :dependent => :destroy
	has_many :messages, :dependent => :destroy
	has_many :contacts, :dependent => :destroy

	def set_cached_password(session,password)
		if $defaults['session_encryption']
			session[:session_salt] = generate_salt
			session[:user_password] = EzCrypto::Key.encrypt_with_password($defaults['session_password'], session[:session_salt], password)
		else
			session[:user_password] = password
		end
	end

	def get_cached_password(session)
		if $defaults['session_encryption']
			EzCrypto::Key.decrypt_with_password($defaults['session_password'], session[:session_salt], session[:user_password])
		else
			session[:user_password]
		end
	end

	def generate_salt
		(0...8).map{65.+(rand(25)).chr}.join
	end

	def full_name
        first_name + " " + last_name
	end

	def full_address
        if email =~ /\@/
            email
        else
            email + "@" + domain
        end
	end

	def username
        email.gsub(/\@/,"_").gsub(/\./,"_")
	end

end
