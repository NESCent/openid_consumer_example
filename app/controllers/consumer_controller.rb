require 'pathname'

require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'
require 'openid/store/filesystem'

class ConsumerController < ApplicationController
  layout nil

  def index
    # render an openid form
    @providers = {"Google" => "https://www.google.com/accounts/o8/id" ,"Yahoo" => "https://yahoo.com", "Other" => "Please Enter your OpenID Identifier"}
  end

  def start
    begin
      # The URI of the user's OpenID
      identifier = params[:openid_identifier]
      if identifier.nil?
        flash[:error] = "Enter an OpenID identifier"
        redirect_to :action => 'index'
        return
      end
      # Create an OpenID Consumer Request and discover
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{identifier}: #{e}"
      redirect_to :action => 'index'
      return
    end
    # Request Attributes for name and email address
    # if Attribute Exchange (ax) selected
    if params[:use_ax]
      axreq = OpenID::AX::FetchRequest.new
        # these work for google
		attribute = OpenID::AX::AttrInfo.new("http://openid.net/schema/contact/email", "email", true);
		axreq.add(attribute)
		attribute = OpenID::AX::AttrInfo.new("http://openid.net/schema/namePerson/first", "firstName", true);
		axreq.add(attribute)
		attribute = OpenID::AX::AttrInfo.new("http://openid.net/schema/namePerson/last", "lastName", true);
	    axreq.add(attribute)
	    # this works for yahoo
	    attribute = OpenID::AX::AttrInfo.new("http://openid.net/schema/namePerson", "fullName", true);
	    axreq.add(attribute)
        oidreq.add_extension(axreq)
        oidreq.return_to_args['did_ax'] = 'y'
    end
    
    # Request Simple Registration data if selected
    if params[:use_sreg]
      sregreq = OpenID::SReg::Request.new
      # required fields
      sregreq.request_fields(['email','nickname'], true)
      # optional fields
      sregreq.request_fields(['dob', 'fullname'], false)
      oidreq.add_extension(sregreq)
      oidreq.return_to_args['did_sreg'] = 'y'
    end
    # Provider Authentication Policy Extension
    # Used here to limit the maximum age of the session
	if params[:use_pape]
      papereq = OpenID::PAPE::Request.new
      papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
      papereq.max_auth_age = 2*60*60
      oidreq.add_extension(papereq)
      oidreq.return_to_args['did_pape'] = 'y'
    end
    # Force POST by increasing the request size
    if params[:force_post]
      oidreq.return_to_args['force_post']='x'*2048
    end
    # URL to return to: this controller's complete action
    return_to = url_for :action => 'complete', :only_path => false
    # Authentication realm: The URL of this controller's index method
    realm = url_for :action => 'index', :id => nil, :only_path => false

	# Send the request
    if oidreq.send_redirect?(realm, return_to, params[:immediate])
      redirect_to oidreq.redirect_url(realm, return_to, params[:immediate])
    else
      render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
    end
  end

  def complete
  	# Receives request after Provider authenticates (or fails)
    # FIXME - url_for some action is not necessarily the current URL.
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}.reject{|k,v| k == 'action' || k == 'controller'}
    # Populate a response object
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
    when OpenID::Consumer::FAILURE
      if oidresp.display_identifier
        flash[:error] = ("Verification of #{oidresp.display_identifier}"\
                         " failed: #{oidresp.message}")
      else
        flash[:error] = "Verification failed: #{oidresp.message}"
      end
    when OpenID::Consumer::SUCCESS
      flash[:success] = ("Verification of #{oidresp.display_identifier}"\
                         " succeeded.")
	  if params[:did_ax]
	  	ax_resp = OpenID::AX::FetchResponse.from_success_response(oidresp)
	  	ax_message = "Attribute Exchange was requested"
	  	if ax_resp == nil || ax_resp.data.empty?
	  		ax_message << ", but none was returned."
	  	else
	  		ax_resp.data.each {|k,v|
	  			ax_message << "<br/><b>#{k}</b>: #{v}"
			}
	  	end
	  	flash[:ax_results] = ax_message
	  end
      if params[:did_sreg]
        sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
        sreg_message = "Simple Registration data was requested"
        if sreg_resp.empty?
          sreg_message << ", but none was returned."
        else
          sreg_message << ". The following data were sent:"
          sreg_resp.data.each {|k,v|
            sreg_message << "<br/><b>#{k}</b>: #{v}"
          }
        end
        flash[:sreg_results] = sreg_message
      end
      if params[:did_pape]
        pape_resp = OpenID::PAPE::Response.from_success_response(oidresp)
        pape_message = "A phishing resistant authentication method was requested"
        if pape_resp.auth_policies.member? OpenID::PAPE::AUTH_PHISHING_RESISTANT
          pape_message << ", and the server reported one."
        else
          pape_message << ", but the server did not report one."
        end
        if pape_resp.auth_time
          pape_message << "<br><b>Authentication time:</b> #{pape_resp.auth_time} seconds"
        end
        if pape_resp.nist_auth_level
          pape_message << "<br><b>NIST Auth Level:</b> #{pape_resp.nist_auth_level}"
        end
        flash[:pape_results] = pape_message
      end
    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    else
    end
    redirect_to :action => 'index'
  end

  private

  def consumer
    if @consumer.nil?
      dir = Pathname.new(Rails.root).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end
end
