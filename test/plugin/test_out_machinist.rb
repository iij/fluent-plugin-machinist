require "helper"
require "fluent/plugin/out_machinist.rb"

class MachinistOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
    endpoint_url https://example.org/gateway
    agent_id THIS_IS_AGENTID
    api_key THIS_IS_API_KEY
    use_ssl true
    verify_ssl true

    value_key VALUE_KEY
    value_keys VALUE_KEY0,VALUE_KEY1

    namespace NAMESPACE
    namespace_key NAMESPACE_KEY

    tags TAG_KEY0:TAG_VALUE0,TAG_KEY1:TAG_VALUE1
    tag_keys TAG_KEY2,TAG_KEY3
  ]

  test "configure" do
    d = create_driver(CONFIG)

    assert_equal "https://example.org/gateway", d.instance.endpoint_url
    assert_equal "THIS_IS_AGENTID", d.instance.agent_id
    assert_equal "THIS_IS_API_KEY", d.instance.api_key
    assert_true d.instance.use_ssl
    assert_true d.instance.verify_ssl
    assert_equal "VALUE_KEY", d.instance.value_key
    assert_equal ["VALUE_KEY0","VALUE_KEY1"], d.instance.value_keys
    assert_equal "NAMESPACE", d.instance.namespace
    assert_equal({"TAG_KEY0"=>"TAG_VALUE0", "TAG_KEY1"=>"TAG_VALUE1"}, d.instance.tags)
    assert_equal ["TAG_KEY2", "TAG_KEY3"], d.instance.tag_keys
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::MachinistOutput).configure(conf)
  end
end
