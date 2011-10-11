require 'new_relic/agent/method_tracer'

Drop.instance_eval do
  class << self
    include NewRelic::Agent::MethodTracer

    add_method_tracer :find,               'Custom/Drop/find'
    add_method_tracer :fetch_drop_content, 'Custom/Drop/fetch_drop_content'
  end
end

Drop.class_eval do
  include NewRelic::Agent::MethodTracer

  add_method_tracer :content
  add_method_tracer :lexer_name
  add_method_tracer :raw
  add_method_tracer :parse_markdown
  add_method_tracer :highlight_code
end

Domain.instance_eval do
  class << self
    include NewRelic::Agent::MethodTracer

    add_method_tracer :find,                 'Custom/Domain/find'
    add_method_tracer :fetch_domain_content, 'Custom/Domain/fetch_domain_content'
  end
end
