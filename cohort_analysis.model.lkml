connection: "thelook"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

explore: users {
  always_filter: {
    filters: {
      field: users.date_picker
      value: "Week"
    }
  }
  join: orders {
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship : one_to_many
  }
  join: order_items {
    sql_on: ${order_items.order_id} = ${orders.id} ;;
    relationship : one_to_many
  }
  join: user_cohort_size {
    sql_on: ${users.account_creation_timeframe}=${user_cohort_size.created_timeframe} ;;
#     sql_on:
#
#       {% assign var=_filters['users.date_picker'] %}
#       {% if var == "Month" %}
#         ${user_cohort_size.created_timeframe} = ${users.created_month}
#       {% elsif var == 'Week' %}
#         ${user_cohort_size.created_timeframe} = ${users.created_week}
#       {% elsif var == 'Day' %}
#         ${user_cohort_size.created_timeframe} = ${users.created_date}
#       {% endif %}
#       ;;
# sql_on:
#          ${user_cohort_size.created_timeframe} = (case when '{% parameter users.date_picker %}' = 'Day' then ${users.created_date}
#                                                         when '{% parameter users.date_picker %}' = 'Month' then ${users.created_month}
#                                                         when '{% parameter users.date_picker %}' = 'Week' then ${users.created_week}
#                                                         end)
#       ;;
      relationship: many_to_one
  }
}

explore: user_cohort_size {
  join: users {
    sql_on: ${users.created_date} = ${user_cohort_size.created_timeframe} ;;
  }
}
