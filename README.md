# Fluent::Plugin::Machinist

## Overview


[Fluentd](http://fluentd.org/) input plugin that forwards record to Machinist

- [Machinist](https://machinist.iij.jp/)


## Installation

install from rubygems

```
gem install fluent-plugin-machinist
or
fluent-gem install fluent-plugin-machinist
```

or build and install

```
git clone https://github.com/iij/fluent-plugin-machinist.git
cd fluent-plugin-machinist
rake build
gem install pkg/fluent-plugin-machinist-0.1.0.gem
```

## Configuration

```
<match test.***>
    @type machinist

    endpoint_url https://gw.machinist.iij.jp/gateway
    agent_id WHATEVER_AGENT_ID_HERE
    api_key WHATEVER_API_KEY_HERE
    use_ssl true
    verify_ssl true

    value_key temp

    # optional parameters
    namespace mydesk
    tags floor:17F,sensor:wionode
</match>
```

```
<match test.***>
    @type machinist

    endpoint_url https://gw.machinist.iij.jp/gateway
    agent_id WHATEVER_AGENT_ID_HERE
    api_key WHATEVER_API_KEY_HERE
    use_ssl true
    verify_ssl true

    value_keys temp,humid

    # optional parameters
    namespace_key location
    tag_keys floor,sensor
</match>
```


**endpoint\_url**

URL where the plugin does POST record (required).

**agent\_id**

Agent ID is used to authenticate to endpoint\_url (required).

**api_key**

Key used to authenticate to endpoint\_url (required).

**use\_ssl**

Whether the plugin use ssl to communicate endpoint\_url. Required to be true if
endpoint\_url is "https://".
(Default: false)

**value\_key**

Specifying which key and value to be used as Machinist metric.
The plugin extracts entry with matching key in record and expand key,value into "name","value" hash.

```
Example: 
if
  recored is  {"hoge":"fuga", "temp": "28.0", "humid": "50.0" }
  "value_key" is "temp"
then
  generates metrics as [{"name": "temp", "value": 28.0}]
```

Either value\_key or value\_keys is mutually required.

**value\_keys**

Specifying which keys and values to be used as Machinist metric.
Unlike value\_key, this accepts array of keys.

```
Example: 
if
  recored is  {"hoge":"fuga", "temp": "28.0", "humid": "50.0" }
  "value_keys" is "temp,humid"
then
  generates metrics as [{"name": "temp", "value": 28.0}, {"name": "humid", "value": 50.0}]
```

value\_keys is mutually exclusive with value\_key.

**namespace**

Specifying static namespace to be used in metric (string).


```
if
  namespace is "mydesk"
  recored is  {"hoge":"fuga", "temp": "28.0", "humid": "50.0" }
  "value_key" is "temp"
then
  generates metrics as [{"name":"temp", "value":28.0, "namespace":"mydesk"]
```

**namespace\_key**

Extracts namespace from value for specified key in record (array).

```
if
  namespace_key is "location"
  recored is  {"hoge":"fuga", "temp": "28.0", "humid": "50.0", "location":"myhome" }
  "value_key" is "temp"
then
  generates metrics as [{"name":"temp", "value":28.0, "namespace":"myhome"]
```

**tags**

Specifying static tags to be used in metric (hash).

```
if
  tags is "floor:17F,sensor:wionode"
  recored is  {"hoge":"fuga", "temp": "28.0", "humid": "50.0", "location":"myhome" }
  "value_key" is "temp"
then
  generates metrics as [{"name":"temp", "value":28.0, "tags":{"floor":"17F", "sensor":"wionode"}}]
```

**tag\_keys**

Extracts tags from specified keys in record (array).

```
if
  tag_keys is "floor,sensor"
  recored is  {"hoge":"fuga", "temp": "28.0", "humid": "50.0", "location":"myhome", "floor":"18F", "sensor":"wionode" }
  "value\_key" is "temp"
then
  generates metrics as [{"name":"temp", "value":28.0, "tags":{"floor":"18F", "sensor":"wionode"}}]
```

## TODO

- "meta" support

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iij/fluent-plugin-machinist


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

