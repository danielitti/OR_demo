view: mainnet {
  derived_table: {
    sql:  SELECT *,
          CASE when errors = '[]'
            then false
            else true
          END as error_flag,
          CASE
            when charindex('[URL]',substring(query,0,15)) > 0 then 'URL'
            when charindex('binary',substring(query,0,15)) > 0 then 'Binary'
            when charindex('https://',substring(query,0,25)) > 0 AND charindex('api.',substring(query,0,25)) > 0 then 'API HTTPS'
            when charindex('https://',substring(query,0,25)) > 0 AND charindex('ww.',substring(query,0,25)) > 0 then 'API WWW'
            else 'Other'
          END as query_type,
          CASE
            when charindex('random.org',substring(query,0,1000)) > 0 OR datasource = 'random' then true
            else false
          END as gambling_related_flag
          FROM public.contracts;;
  }
  dimension_group: datetime {
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
    sql: ${TABLE}.datetime ;;
  }

  dimension: errors {
    group_label: "Errors"
    type: string
    sql: ${TABLE}.errors ;;
  }

  dimension: error_flag {
    group_label: "Errors"
    type: yesno
    sql: ${TABLE}.error_flag ;;
  }

  dimension: gambling_related_flag {
    label: "Is Gambling Related?"
    type: yesno
    sql: ${TABLE}.gambling_related_flag ;;
  }

  dimension: gas {
    type: number
    sql: ${TABLE}.gas ;;
  }

  dimension: proof_type {
    label: "Proof Source"
    group_label: "Proof"
    type: number
    sql: ${TABLE}.proof_type ;;
  }

  dimension: proof_type_type {
    label: "Proof Type"
    group_label: "Proof"
    type: number
    sql: ${TABLE}.proof_type / 16 ;;
  }

  dimension: proof_type_source {
    label: "Proof Type"
    group_label: "Proof"
    type: number
    sql: mod(${TABLE}.proof_type,16) ;;
  }

  dimension: query_creator_id {
    type: string
    sql: ${TABLE}.query_creator_id ;;
  }

  dimension: query_id {
    type: string
    sql: ${TABLE}.query_id ;;
  }

  dimension: check_op {
    type: string
    sql: ${TABLE}.check_op ;;
  }

  dimension: context_name {
    type: string
    sql: ${TABLE}.context_name ;;
  }


  dimension: data_source {
    type: string
    sql: ${TABLE}.datasource ;;
  }

  dimension: query {
    group_label: "Query"
    type: string
    sql: ${TABLE}.query ;;
  }

  dimension: query_type {
    group_label: "Query"
    type: string
    sql: ${TABLE}.query_type ;;
  }

  measure: count {
    group_label: "Calls"
    label: "Total Calls"
    type: count
    drill_fields: []
  }

  measure: count_error {
    group_label: "Calls"
    label: "Calls With Error"
    type: count
    filters: {
      field: error_flag
      value: "yes"
    }
    drill_fields: []
  }

  measure: count_no_error {
    group_label: "Calls"
    label: "Calls No Error"
    type: count
    filters: {
      field: error_flag
      value: "no"
    }
    drill_fields: []
  }

  measure: count_error_ratio {
    group_label: "Calls"
    label: "Calls Error %"
    type: number
    sql: COALESCE(${count_error},0)*1.00/NULLIF(${count},0)  ;;
    value_format_name: percent_2
  }

  measure: count_gambling_related {
    group_label: "Calls"
    label: "Calls Gambling Related"
    type: count
    filters: {
      field: gambling_related_flag
      value: "yes"
    }
    drill_fields: []
  }

  measure: count_no_gambling {
    group_label: "Calls"
    label: "Calls No Gambling"
    type: count
    filters: {
      field: gambling_related_flag
      value: "no"
    }
    drill_fields: []
  }

  measure: count_gambling_related_ratio {
    group_label: "Calls"
    label: "Calls Gambling Related %"
    type: number
    sql: COALESCE(${count_gambling_related},0)*1.00/NULLIF(${count},0)  ;;
    value_format_name: percent_2
  }

  measure: creators {
    label: "Creators"
    type: count_distinct
    sql: ${TABLE}.query_creator_id ;;
  }

  measure: distinct_context{
    group_label: "Context"
    label: "Distinct Context"
    type: count_distinct
    sql: ${TABLE}.context_name;;
  }

  measure: total_context{
    group_label: "Context"
    label: "Total Context"
    type: count
    sql: ${TABLE}.context_name;;
  }

  measure: gas_used {
    label: "Trx Gas"
    type: sum
    sql: ${TABLE}.gas ;;
  }

  measure: avg_gas_used {
    label: "Average Trx Gas"
    type: average
    sql: ${TABLE}.gas ;;
  }

}
