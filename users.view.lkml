view: users {
  sql_table_name: demo_db.users ;;

  parameter: label_param_string {
    type: string
  }

  parameter: unquoted {
    type: unquoted
    allowed_value: {
      label: "c"
      value: "Sale Price"
    }
  }

  parameter: date_picker {
    type: unquoted
    allowed_value: {
      label: "Day"
      value: "Day"
    }
    allowed_value: {
      label: "Week"
      value: "Week"
    }
    allowed_value: {
      label: "Month"
      value: "Month"
    }
  }

  dimension: date_picker_dim {
    type: string
    sql: '{% parameter date_picker %}' ;;
  }

  dimension: date_picker_dim_formatted {
    type: string
    sql:
    {% if users.date_picker_dim._value == "Month" %}
'yar'
       {% users.date_picker_dim._value == 'Week' %}
'yaar'
{% elsif users.date_picker_dim._value == 'Day' %}
'yaaar'
{% endif %}
      ;;
  }

  dimension: id {
    primary_key: yes
    #label: "{% parameter label_param_string %}"
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: account_creation_timeframe {
    type: string
    sql:
        case when '{% parameter date_picker %}' = 'Day' then ${created_date}
              when '{% parameter date_picker %}' = 'Month' then ${created_month}
              when '{% parameter date_picker %}' = 'Week' then ${created_week}
              end
    ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    html:
    {% if users.count._value > 400 %}
    <p style="color: black; background-color: lightblue; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% elsif users.count._value > 200 %}
    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% endif %}
    ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    html:
    {% if value > 400 %}
    <p style="color: black; background-color: lightblue; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% elsif value > 200 %}
    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% endif %}
    ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      last_name,
      first_name,
      events.count,
      orders.count,
      user_data.count
    ]
  }
}
