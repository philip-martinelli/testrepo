  datagroup: orders_datagroup {
    sql_trigger: SELECT max(created_at) FROM demo_db.orders ;;
    max_cache_age: "24 hours"
  }
