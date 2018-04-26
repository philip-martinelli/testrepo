view: orders {
  sql_table_name: demo_db.orders ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
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

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: cohort_by_activity {
    type: string
    sql:  concat('D',abs(DATEDIFF(${users.created_date}, ${created_date}))) ;;

  }

  dimension: days_since_account_creation {
    hidden: no
    type: number
    sql: DATEDIFF(${created_raw}, ${users.created_raw});;
  }

  dimension: days_since_account_creation_tier_copy {
    type: tier
    tiers: [1,3,6,12,24]
    style: integer
    sql: ${days_since_account_creation} ;;
  }

  dimension: days_since_account_creation_tier {
    case: {
      when: {
        sql: ${days_since_account_creation} < 8 ;;
        label: " 7 or Less"
      }
      when: {
        sql: ${days_since_account_creation} < 15 ;;
        label: "  8-14"
      }
      when: {
        sql: ${days_since_account_creation} < 29;;
        label: "   15-28"
      }
      when: {
        sql: ${days_since_account_creation} < 36 ;;
        label: "    29-35"
      }
      else: "      36+"
    }
  }

  dimension: months_since_acount_creation {
    type: number
    sql: FLOOR(${days_since_account_creation}/(30)) ;;
  }

  dimension: months_since_account_creation_tier_copy {
    type: tier
    tiers: [1,3,6,12,24]
    style: integer
    sql: ${months_since_acount_creation} ;;
  }

  dimension: months_since_account_creation_tier {
    case: {
      when: {
        sql: ${months_since_acount_creation} < 1 ;;
        label: " Less than 1"
      }
      when: {
        sql: ${months_since_acount_creation} < 3 ;;
        label: "  1-2"
      }
      when: {
        sql: ${months_since_acount_creation} < 6;;
        label: "   3-5"
      }
      when: {
        sql: ${months_since_acount_creation} < 12 ;;
        label: "    6-11"
      }
      when: {
        sql: ${months_since_acount_creation} < 24;;
        label: "     12-23"
      }
      else: "      24+"
    }
  }

  dimension: weeks_since_account_creation {
    type: number
    sql: FLOOR(${days_since_account_creation}/(7)) ;;
  }

  dimension: weeks_since_account_creation_tier {
    case: {
      when: {
        sql: ${weeks_since_account_creation} < 4 ;;
        label: " Less than 4"
      }
      when: {
        sql: ${weeks_since_account_creation} < 8 ;;
        label: "  4-7"
      }
      when: {
        sql: ${weeks_since_account_creation} < 12;;
        label: "   7-11"
      }
      else: "   12+"
    }
  }

  dimension: time_interval_since_account_creation {
    type: string
    sql:
        case when '{% parameter users.date_picker %}' = 'Day' then ${days_since_account_creation_tier}
              when '{% parameter users.date_picker %}' = 'Month' then ${months_since_account_creation_tier}
              when '{% parameter users.date_picker %}' = 'Week' then ${weeks_since_account_creation_tier}
              end
    ;;
  }

  measure: percent_of_prev {
    type: percent_of_previous
    sql: ${count} ;;
  }

  measure: count {
    type: count
    drill_fields: [id, users.last_name, users.first_name, users.id, order_items.count]
  }
  measure: total_distinctusers {
    type: sum_distinct
    sql: ${user_id} ;;
  }

  dimension: yn {
    type: yesno
    sql: ${time_interval_since_account_creation} =
    {% assign var=_filters['users.date_picker'] %}
    {% if var == "Month" %}
      select CASE
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(30))) < 1  THEN ' Less than 1'
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(30))) < 3  THEN '  1-2'
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(30))) < 6 THEN '   3-5'
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(30))) < 12  THEN '    6-11'
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(30))) < 24 THEN '     12-23'
        ELSE '      24+'
        END
      from orders o
      join users u
      on .id = .user_id
      where
      o.user_id = ${orders.user_id}
      and o.id = ${orders.id}
      and DATE_FORMAT(CONVERT_TZ(u.created_at,'UTC','America/Los_Angeles'),'%Y-%m') = ${user_cohort_size.created_timeframe} limit 1)
    {% elsif var == 'Week' %}
      select CASE
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(7))) < 4  THEN ' Less than 4'
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(7))) < 8  THEN '  4-7'
        WHEN (FLOOR((DATEDIFF(orders.created_at, users.created_at))/(7))) < 12 THEN '   7-11'
        ELSE '   12+'
        END
      from orders o
      join users u
      on .id = .user_id
      where
      o.user_id = ${orders.user_id}
      and o.id = ${orders.id}
      and DATE(CONVERT_TZ(u.created_at ,'UTC','America/Los_Angeles')) = ${user_cohort_size.created_timeframe} limit 1)
    {% elsif var == 'Day' %}
      (select CASE
        WHEN (DATEDIFF(o.created_at, u.created_at)) < 8  THEN ' 7 or Less'
        WHEN (DATEDIFF(o.created_at, u.created_at)) < 15  THEN '  8-14'
        WHEN (DATEDIFF(o.created_at, u.created_at)) < 29 THEN '   15-28'
        WHEN (DATEDIFF(o.created_at, u.created_at)) < 36  THEN '    29-35'
        ELSE '      36+'
        END
      from orders o
      join users u
      on .id = .user_id
      where
      o.user_id = ${orders.user_id}
      and o.id = ${orders.id}
      and DATE(CONVERT_TZ(u.created_at ,'UTC','America/Los_Angeles')) = ${user_cohort_size.created_timeframe} limit 1)
    {% endif %}
    ;;
  }
}
