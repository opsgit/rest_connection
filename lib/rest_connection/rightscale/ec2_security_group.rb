#--
# Copyright (c) 2010-2012 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Ec2SecurityGroup
  include RightScale::Api::Base
  extend RightScale::Api::BaseExtend

  # NOTE - Create, Destroy, and Update require "security_manager" permissions
  # NOTE - Can't remove rules, can only add
  def add_rule(opts={})
    opts.each { |k,v| opts["#{k}".to_sym] = v }
    update_types = [
      :name => [:owner, :group],
      :cidr_ips => [:cidr_ip, :protocol, :from_port, :to_port],
      :group => [:owner, :group, :protocol, :from_port, :to_port],
    ]
    type = (opts[:protocol] ? (opts[:cidr_ip] ? :cidr_ips : :group) : :name)
    unless update_types[type].reduce(true) { |b,field| b && opts[field] }
      arg_expectation = update_types.values.pretty_inspect
      raise ArgumentError.new("add_rule requires one of these groupings: #{arg_expectation}")
    end

    params = {}
    update_types[type].each { |field| params[field] = opts[field] }

    uri = URI.parse(self.href)
    connection.put(uri.path, params)

    self.reload
  end
end
