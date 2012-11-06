require 'logger'
require 'net/http'
require 'net/https'

class NetsuiteClient
  include NetSuite::SOAP

  class NetsuiteHeader < SOAP::Header::SimpleHandler
    def initialize(prefs = {})
      @prefs = self.class::DefaultPrefs.merge(prefs)
      super(XSD::QName.new(nil, self.class::Name))
    end

    def on_simple_outbound
      @prefs
    end
  end

  class SearchPreferencesHeaderHandler < NetsuiteHeader
    Name = 'searchPreferences'
    DefaultPrefs = {:bodyFieldsOnly => false, :pageSize => 25}
  end

  class PreferencesHeaderHandler < NetsuiteHeader
    Name = 'preferences'
    DefaultPrefs = {:warningAsError => false, :ignoreReadOnlyFields => true}
  end

  class PassportHeaderHandler < NetsuiteHeader
    Name = 'passport'
    DefaultPrefs = {:account => '', :email => '', :password => ''}
  end

  attr_accessor :logger

  def initialize(config = {})
    @config = config

    @driver = NetSuitePortType.new(@config[:endpoint_url] || NetSuitePortType::DefaultEndpointUrl)

    if @config[:role]
      role = {:xmlattr_internalId => config[:role]}
    end

    @driver.headerhandler.add(PassportHeaderHandler.new(:email => @config[:email], :password => @config[:password], :account => @config[:account_id], :role => role))
    @driver.headerhandler.add(PreferencesHeaderHandler.new)      
    @driver.headerhandler.add(SearchPreferencesHeaderHandler.new)
  end

  def debug=(value)
    @driver.wiredump_dev = value == true ? $stderr : nil
  end

  def find_by_internal_id(klass, id)
    find_by_internal_ids(klass, [id])[0]
  end

  def find_by_internal_ids(klass, ids)
    basic = constantize(klass).new
    basic.internalId = SearchMultiSelectField.new
    basic.internalId.xmlattr_operator = SearchMultiSelectFieldOperator::AnyOf

    records = []
    ids.each do |id|
      record = RecordRef.new
      record.xmlattr_internalId = id
      records << record
    end

    basic.internalId.searchValue = records

    full_basic_search(basic)
  end

  # Only supports equality for integers and strings for now.
  def find_by(klass, name, value)
    basic = constantize(klass).new

    ref = nil
    case value.class.to_s
    when 'Fixnum'
      ref = basic.send("#{name}=".to_sym, SearchLongField.new)
      ref.xmlattr_operator = SearchLongFieldOperator::EqualTo

    else
      ref = basic.send("#{name}=".to_sym, SearchStringField.new)
      ref.xmlattr_operator = SearchStringFieldOperator::Is
    end

    ref.searchValue = value

    full_basic_search(basic)
  end

  def get(klass, id)
    ref = RecordRef.new
    ref.xmlattr_type = constantize(klass)
    ref.xmlattr_internalId = id

    res = @driver.get(GetRequest.new(ref))
    res && res.readResponse.status.xmlattr_isSuccess ? res.readResponse.record : nil
  end

  def get_all(klass)
    ref = GetAllRecord.new
    ref.xmlattr_recordType = constantize(klass)

    res = @driver.getAll(GetAllRequest.new(ref))
    res && res.getAllResult.status.xmlattr_isSuccess ? res.getAllResult.recordList : []
  end

  def add(ref)
    res = @driver.add(AddRequest.new(ref))
    NetsuiteResult.new(res.writeResponse)
  end

  def update(ref)
    res = @driver.update(UpdateRequest.new(ref))
    NetsuiteResult.new(res.writeResponse)
  end

  def delete(ref)
    r = RecordRef.new
    r.xmlattr_type = ref.class.to_s.split('::').last.sub(/^(\w)/) {|s|$1.downcase}
    r.xmlattr_internalId = ref.xmlattr_internalId

    res = @driver.delete(DeleteRequest.new(r))
    NetsuiteResult.new(res.writeResponse)
  end

  def get_select_value(klass, field)
    fieldDescription = GetSelectValueFieldDescription.new
    fieldDescription.recordType = constantize(klass)
    fieldDescription.field = field
    res = @driver.getSelectValue(:fieldDescription => fieldDescription, :pageIndex => 1).getSelectValueResult
    res.status.xmlattr_isSuccess ? res.baseRefList : nil
  end

  # Get the full result set (possibly across multiple pages).
  def full_basic_search(basic)
    records, res = exec_basic_search(basic)
    unless res && res.status.xmlattr_isSuccess
      return []
    end

    if res.totalPages > 1
      while res.pageIndex < res.totalPages
        next_records, res = exec_next_search(res.searchId, res.pageIndex+1)
        records += next_records
      end
    end

    records
  end

  private

  # Get the first page of search results for basic search.
  def exec_basic_search(basic)
    exec_with_retry do
      search = constantize(basic.class.to_s.sub(/Basic/, '')).new
      search.basic = basic

      res = @driver.search(search)
      return res.searchResult.recordList, res.searchResult
    end
  end

  # Get the next page of results.
  def exec_next_search(search_id, page)
    exec_with_retry do
      res = @driver.searchMoreWithId("searchId" => search_id, "pageIndex" => page)
      return res.searchResult.recordList, res.searchResult
    end
  end

  def exec_with_retry(&block)
    tries = 5

    begin
      yield

    rescue => e

      logger.warn "Exception: #{e.message}"
      sleep 0.1

      if tries > 0
        tries -= 1
        logger.debug "#{$$} retrying, tries left: #{tries}"
        retry
      end

      raise NetsuiteException.new(e)
    end
  end

  def constantize(klass)
    klass.constantize

    rescue NameError
      "NetSuite::SOAP::#{klass}".constantize
  end
end
