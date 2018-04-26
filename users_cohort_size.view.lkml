view: user_cohort_size {
  derived_table: {
  sql:
      SELECT
      {% assign var=_filters['users.date_picker'] %}
      {% if var == "Month" %}
        DATE_FORMAT(CONVERT_TZ(u.created_at,'UTC','America/Los_Angeles'),'%Y-%m')
      {% elsif var == 'Week' %}
        DATE_FORMAT(TIMESTAMP(DATE(DATE_ADD(CONVERT_TZ(u.created_at ,'UTC','America/Los_Angeles'),INTERVAL (0 - MOD((DAYOFWEEK(CONVERT_TZ(u.created_at ,'UTC','America/Los_Angeles')) - 1) - 1 + 7, 7)) day))), '%Y-%m-%d')
      {% elsif var == 'Day' %}
        DATE(CONVERT_TZ(u.created_at ,'UTC','America/Los_Angeles'))
      {% endif %} as created_timeframe
        , COUNT(id) as cohort_size
      FROM users u
      -- WHERE
        -- Insert filters here using a condition statement, you may add as many filters as desired
      --  {% condition users.age %} u.age {% endcondition %}
       -- AND {% condition users.state %} u.state {% endcondition %}
      GROUP BY 1 ;;

}
    dimension: created_timeframe {
      primary_key: yes
    }

    dimension: cohort_size {
      type: number
    }

    measure: total_cohort_size {
      type: sum
      sql: ${cohort_size} ;;
      }

        measure: total_revenue_over_total_cohort_size {
          type: number
          sql: ${order_items.total_sale_price} / ${total_cohort_size} ;;
          value_format: "$#,##0"
        }



}
