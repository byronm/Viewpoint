require 'ews/folder_accessors'
require 'ews/item_accessors'
require 'ews/message_accessors'
require 'ews/mailbox_accessors'
require 'ews/push_subscription_accessors'

# This class is the glue between the Models and the Web Service.
class Viewpoint::EWSClient
  include Viewpoint::EWS
  include Viewpoint::EWS::FolderAccessors
  include Viewpoint::EWS::ItemAccessors
  include Viewpoint::EWS::MessageAccessors
  include Viewpoint::EWS::MailboxAccessors
  include Viewpoint::EWS::PushSubscriptionAccessors

  # The instance of Viewpoint::EWS::SOAP::ExchangeWebService 
  attr_reader :ews

  # Initialize the EWSClient instance.
  # @param [String] endpoint The EWS endpoint we will be connecting to
  # @param [String] user The user to authenticate as. If you are using
  #   NTLM or Negotiate authentication you do not need to pass this parameter.
  # @param [String] pass The user password. If you are using NTLM or
  #   Negotiate authentication you do not need to pass this parameter.
  # @param [Hash] opts Various options to pass to the backends
  # @option opts [String] :server_version The Exchange server version to
  #   target. See the VERSION_* constants in
  #   Viewpoint::EWS::SOAP::ExchangeWebService.
  # @option opts [Object] :http_class specify an alternate HTTP connection class.
  # @option opts [Hash] :http_opts options to pass to the connection
  def initialize(endpoint, user = nil, pass = nil, opts = {})
    http_klass = opts[:http_class] || Viewpoint::EWS::Connection
    con = http_klass.new(endpoint, opts[:http_opts] || {})
    con.set_auth(user,pass) if(user && pass)
    @ews = SOAP::ExchangeWebService.new(con, opts)
  end

  def auto_deepen=(deepen)
    @ews.auto_deepen = (deepen ? true : false)
  end


  private


  # This method also exists in EWS::Types, but there is a lot of other stuff
  # in there that I didn't want to include directly in this class.
  def class_by_name(cname)
    if(cname.instance_of? Symbol)
      cname = cname.to_s.camel_case
    end
    Viewpoint::EWS::Types.const_get(cname)
  end

  # Used for multiple accessors
  def merge_restrictions!(obj, merge_type = :and)
    if obj.opts[:restriction] && !obj.opts[:restriction].empty? && !obj.restriction.empty?
      obj.opts[:restriction] = {
        merge_type => [
          obj.opts.delete(:restriction),
          obj.restriction
        ]
      }
    elsif !obj.restriction.empty?
      obj.opts[:restriction] = obj.restriction
    end
  end

end
