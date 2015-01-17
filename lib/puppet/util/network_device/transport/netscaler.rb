require 'puppet/util/network_device'
require 'puppet/util/network_device/transport'
require 'puppet/util/network_device/transport/base'

class Puppet::Util::NetworkDevice::Transport::Netscaler < Puppet::Util::NetworkDevice::Transport::Base
  attr_reader :connection

  def initialize(url, _options = {})
    require 'faraday'
    @connection = Faraday.new(url: url, ssl: { verify: false })
  end

  def call(url=nil)
    result = connection.get("/nitro/v1#{url}")
    type = url.split('/')[1]
    output = JSON.parse(result.body)
    if url.split('/')[2]
      output[url.split('/')[2]]
    elsif output["#{type}objects"]
      output["#{type}objects"]['objects']
    end
  rescue JSON::ParserError
    return nil
  end

  def failure?(result)
    unless result.status == 200 or result.status == 201
      fail("REST failure: HTTP status code #{result.status} detected.  Body of failure is: #{result.body}")
    end
  end

  def post(url, json)
    if valid_json?(json)
      result = connection.post do |req|
        req.url "/nitro/v1#{url}"
        req.headers['Content-Type'] = 'application/json'
        req.body = json
      end
      failure?(result)
      return result
    else
      fail('Invalid JSON detected.')
    end
  end

  def put(url, json)
    if valid_json?(json)
      result = connection.put do |req|
        req.url "/nitro/v1#{url}"
        req.headers['Content-Type'] = 'application/json'
        req.body = json
      end
      failure?(result)
      return result
    else
      fail('Invalid JSON detected.')
    end
  end

  def delete(url)
    result = connection.delete(url)
    failure?(result)
    return result
  end

  def valid_json?(json)
    JSON.parse(json)
    return true
  rescue
    return false
  end

  ## Given a string containing objects matching /Partition/Object, return an
  ## array of all found objects.
  #def find_monitors(string)
  #  return nil if string.nil?
  #  if string == "default"
  #    ["default"]
  #  elsif string == "/Common/none"
  #    ["none"]
  #  else
  #    string.scan(/(\/\S+)/).flatten
  #  end
  #end

  ## Monitoring:  Parse out the availability integer.
  #def find_availability(string)
  #  return nil if string.nil?
  #  if string == "default" or string == "none"
  #    return nil
  #  end
  #  # Look for integers within the string.
  #  matches = string.match(/min\s(\d+)/)
  #  if matches
  #    matches[1]
  #  else
  #    "all"
  #  end
  #end
end
