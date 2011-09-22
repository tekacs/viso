require 'new_relic/agent/method_tracer'

Drop.instance_eval do
  class << self
    include NewRelic::Agent::MethodTracer
    add_method_tracer :find, 'Custom/Drop/find'
  end
end

Drop.class_eval do
  include NewRelic::Agent::MethodTracer

  add_method_tracer :content
  add_method_tracer :lexer_name
end

Domain.instance_eval do
  class << self
    include NewRelic::Agent::MethodTracer
    add_method_tracer :find, 'Custom/Domain/find'
  end
end
