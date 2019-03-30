# :nodoc:
module JSON::Serializable
  # ameba:disable Metrics/CyclomaticComplexity
  def to_json(json : ::JSON::Builder, serialization_groups : Array(String), expand : Array(String))
    {% begin %}
      {% properties = {} of Nil => Nil %}
      {% cann = @type.annotation(CrSerializer::ClassOptions) %}
      {% for ivar in @type.instance_vars %}
        {% cr_ann = ivar.annotation(CrSerializer::Options) %}
        {% expansion_ann = ivar.annotation(CrSerializer::Expandable) %}
        {% json_ann = ivar.annotation(JSON::Field) %}
        {% unless (cann && cann[:exclusion_policy] && cann[:exclusion_policy].resolve == CrSerializer::ExclusionPolicy::ExcludeAll) && (!cr_ann || cr_ann[:expose] != true) %}
          {% if (!cr_ann || (cr_ann && (cr_ann[:expose] == true || cr_ann[:expose] == nil))) && (!json_ann || (json_ann && (json_ann[:ignore] == false || json_ann[:ignore] == nil))) %}
            {%
              properties[ivar.id] = {
                key:              ((cr_ann && cr_ann[:serialized_name]) || ivar).id.stringify,
                emit_null:        (cr_ann && cr_ann[:emit_null] == true) ? true : false,
                value:            (cr_ann && cr_ann[:accessor]) ? cr_ann[:accessor] : ivar.id,
                since:            (cr_ann && cr_ann[:since]) ? cr_ann[:since] : nil,
                until:            (cr_ann && cr_ann[:until]) ? cr_ann[:until] : nil,
                groups:           (cr_ann && cr_ann[:groups]) ? cr_ann[:groups] : ["default"],
                expansion:        !!expansion_ann,
                expansion_name:   ((expansion_ann && expansion_ann[:name]) || ivar).id.stringify,
                expansion_method: (expansion_ann && expansion_ann[:getter]) ? expansion_ann[:getter].id : ivar.id,
              }
            %}
          {% end %}
        {% end %}
      {% end %}

        json.object do
          {% for name, value in properties %}
            {% if !value[:emit_null] && (!value[:expansion] && value[:expansion_method]) %} unless {{value[:value]}}.nil?  {% end %}
              {% if value[:since] != nil || value[:until] != nil %}
                if !CrSerializer.version.nil? && SemanticVersion.parse(CrSerializer.version.not_nil!) {% if value[:since] %} >= (SemanticVersion.parse({{value[:since]}})) {% else %} < (SemanticVersion.parse({{value[:until]}})) {% end %}
              {% end %}
                if {{value[:groups]}}.any? { |g| serialization_groups.includes? g}
                  {% if value[:expansion] %}
                    json.field {{value[:key]}} { {{value[:expansion_method]}}.to_json json, serialization_groups, expand } if expand.includes? {{value[:expansion_name]}}
                  {% else %}
                    json.field {{value[:key]}} { {{value[:value]}}.to_json json, serialization_groups, expand }
                  {% end %}
                end
              {% if value[:since] != nil || value[:until] != nil %} end {% end %}
            {% if !value[:emit_null] && (!value[:expansion] && value[:expansion_method]) %} end {% end %}
          {% end %}
          on_to_json(json)
        end
      {% end %}
  end
end
