require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class NetsuiteClientClient < Test::Unit::TestCase
  include NetSuite::SOAP

  def setup
    ENV['NS_ENDPOINT_URL'] ||= NetSuite::SOAP::NetSuitePortType::DefaultEndpointUrl.sub(/webservices/, "webservices.sandbox")

    unless ENV['NS_ACCOUNT_ID'] && ENV['NS_EMAIL'] && ENV['NS_PASSWORD'] 
      puts "Ensure that all your environment variables are set: NS_ACCOUNT_ID, NS_EMAIL, NS_PASSWORD"
      exit(-1)
    end

    @client = NetsuiteClient.new(:account_id => ENV['NS_ACCOUNT_ID'], :email => ENV['NS_EMAIL'], :password => ENV['NS_PASSWORD'], :role => ENV['NS_ROLE'], :endpoint_url => ENV['NS_ENDPOINT_URL'])
    # @client.debug = true
  end

  def test_init
    assert_not_nil @client
  end

  def test_find_by_internal_id
    records = @client.find_by_internal_ids('TransactionSearchBasic', [0])
    assert_equal [], records
  end

  def test_get
    record = @client.get('RecordType::PaymentMethod', 1)
    assert_not_nil record
    assert_equal 1, record.xmlattr_internalId.to_i
    assert_equal 'NetSuite::SOAP::PaymentMethod', record.class.to_s
  end

  def test_get_all
    records = @client.get_all('GetAllRecordType::Currency')
    assert records.any?
    assert records.all? {|r| r.class.to_s == 'NetSuite::SOAP::Currency'}
  end

  def test_get_select_value
    values = @client.get_select_value('RecordType::SupportCase', 'origin')
    assert values.count > 0
    assert values.find {|value| value.name == "Web"}
  end

  def test_add_customer
    customer = Customer.new
    customer.companyName = "Test Inc."
    res = @client.add(customer)
    assert res.success?
  end

  def test_delete_customer
    item = @client.find_by('CustomerSearchBasic', 'companyName', 'Test Inc.')[0]
    assert_not_nil item

    ref = Customer.new
    ref.xmlattr_internalId = item.xmlattr_internalId
    res = @client.delete(ref)
    assert_not_nil res
    assert res.success?
    assert_nil @client.find_by('CustomerSearchBasic', 'companyName', 'Test Inc.')[0]
  end

# inventory item tests are currently disabled
#  FIXME: 2011_2 requires cogs and asset accounts
#  def test_add_inventory_item
#    ref = InventoryItem.new
#    ref.itemId = 'test inventory item'
#    res = @client.add(ref)
#    assert_not_nil res
#    assert res.success? || res.error_code == 'DUP_ITEM'
#  end


# FIXME
#  def test_find_by_item_id
#    test_add_inventory_item
#    item = @client.find_by('ItemSearchBasic', 'itemId', 'test inventory item')
#
#    assert_not_nil item
#    assert_equal 'NetSuite::SOAP::RecordList', item.class.to_s
#    assert_equal 1, item.size
#    assert_equal 'NetSuite::SOAP::InventoryItem', item[0].class.to_s
#  end

# FIXME
#  def test_update_inventory_item
#    test_add_inventory_item
#    new_name = String.random_string
#
#    item = @client.find_by('ItemSearchBasic', 'itemId', 'test inventory item')[0]
#    assert item.displayName != new_name
#    
#    ref = InventoryItem.new
#    ref.xmlattr_internalId = item.xmlattr_internalId
#    ref.displayName = new_name
#    res = @client.update(ref)
#    assert_not_nil res
#    assert res.success?
#    
#    item = @client.find_by('ItemSearchBasic', 'itemId', 'test inventory item')[0]
#    assert item.displayName == new_name
#  end

# FIXME
#  def test_delete_inventory_item
#    test_add_inventory_item
#    item = @client.find_by('ItemSearchBasic', 'itemId', 'test inventory item')[0]
#    assert_not_nil item
#
#    ref = InventoryItem.new
#    ref.xmlattr_internalId = item.xmlattr_internalId
#    res = @client.delete(ref)
#    assert_not_nil res
#    assert res.success?
#    assert_nil @client.find_by('ItemSearchBasic', 'itemId', 'test inventory item')[0]
#  end

end
