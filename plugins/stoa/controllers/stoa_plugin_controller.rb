require 'stoa_plugin/person_fields'

class StoaPluginController < PublicController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  include StoaPlugin::PersonFields

  def authenticate
    if request.ssl? && request.post?
      if params[:login].blank?
        person = Person.find_by_usp_id(params[:usp_id])
        login = person ? person.user.login : nil
      else
        login = params[:login]
      end
      user = User.authenticate(login, params[:password], environment)
      if user
        result = StoaPlugin::PersonApi.new(user.person, self).fields(selected_fields(params[:fields], user))
        result.merge!(:ok => true)
      else
        result = { :error => _('Incorrect user/password pair.'), :ok => false }
      end
      render :text => result.to_json
    else
      render :text => { :error => _('Conection requires SSL certificate and post method.'), :ok => false }.to_json
    end
  end

  def check_usp_id
    begin
      render :text => { :exists => StoaPlugin::UspUser.exists?(params[:usp_id]) && Person.find_by_usp_id(params[:usp_id]).nil? }.to_json
    rescue Exception => exception
      render :text => { :exists => false, :error => {:message => exception.to_s, :backtrace => exception.backtrace} }.to_json
    end
  end

  def check_cpf
    begin
      render :text => { :exists => StoaPlugin::UspUser.find_by_codpes(params[:usp_id]).cpf.present? }.to_json
    rescue Exception => exception
      render :text => { :exists => false, :error => {:message => exception.to_s, :backtrace => exception.backtrace} }.to_json
    end
  end

  private

  def selected_fields(kind, user)
    fields = FIELDS[kind] || FIELDS['essential']
    return fields.reject { |field| !FIELDS['essential'].include?(field) } unless user.person.public_profile
    fields.reject do |field|
      !user.person.public_fields.include?(field) &&
      !FIELDS['essential'].include?(field)
    end
  end

end
