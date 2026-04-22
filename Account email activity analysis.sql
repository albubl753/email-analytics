-- Calculate the total number of accounts per country and rank them
WITH
  total_account AS (
    SELECT
      country,
      COUNT(DISTINCT acs.account_id) AS total_country_account_cnt,
      rank()
        OVER (ORDER BY COUNT(DISTINCT acs.account_id) DESC)
        AS rank_total_country_account_cnt
    FROM `DA.account_session` acs
    JOIN `DA.session_params` sp
      ON acs.ga_session_id = sp.ga_session_id
    GROUP BY 1
  ),


  -- Get account data partitioned by date and country
  account AS (
    SELECT
      date,
      sp.country AS country,
      send_interval,
      is_verified,
      is_unsubscribed,
      COUNT(DISTINCT acc.id) AS account_cnt
    FROM `data-analytics-mate.DA.account` acc
    JOIN `DA.account_session` acs
      ON acc.id = acs.account_id
    JOIN `DA.session` ss
      ON acs.ga_session_id = ss.ga_session_id
    JOIN `DA.session_params` sp
      ON acs.ga_session_id = sp.ga_session_id
    GROUP BY date, sp.country, send_interval, is_verified, is_unsubscribed
  ),


  -- Join total account counts and ranks to the account data
  account_with_ranks AS (
    SELECT
      date,
      acc.country,
      send_interval,
      is_verified,
      is_unsubscribed,
      account_cnt,
      total_country_account_cnt,
      rank_total_country_account_cnt
    FROM account acc
    JOIN total_account ta
      ON acc.country = ta.country
  ),


  -- Get email activity metrics and map them to account data
  email_cnt AS (
    SELECT
      date_add(ss.date, INTERVAL es.sent_date day) AS date,
      country,
      acc.send_interval,
      acc.is_verified,
      acc.is_unsubscribed,
      COUNT(DISTINCT es.id_message) AS sent_msg,
      COUNT(DISTINCT eo.id_message) AS open_msg,
      COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM `DA.email_sent` es
    LEFT JOIN `DA.email_open` eo
      ON es.id_message = eo.id_message
    LEFT JOIN `DA.email_visit` ev
      ON es.id_message = ev.id_message
    JOIN `DA.account` acc
      ON es.id_account = acc.id
    JOIN `DA.account_session` acs
      ON es.id_account = acs.account_id
    JOIN `DA.session_params` sp
      ON acs.ga_session_id = sp.ga_session_id
    JOIN `DA.session` ss
      ON acs.ga_session_id = ss.ga_session_id
    GROUP BY 1, 2, 3, 4, 5
  ),


  -- Calculate total sent emails per country and rank them
  total_email AS (
    SELECT
      country,
      SUM(sent_msg) AS total_country_sent_cnt,
      RANK()
        OVER (ORDER BY SUM(sent_msg) DESC)
        AS rank_total_country_sent_cnt
    FROM email_cnt
    GROUP BY country
  ),


  -- Join total email counts and ranks to the email activity data
  email_with_ranks AS (
    SELECT
      ec.date,
      ec.country,
      ec.send_interval,
      ec.is_verified,
      ec.is_unsubscribed,
      ec.sent_msg,
      ec.open_msg,
      ec.visit_msg,
      te.total_country_sent_cnt,
      te.rank_total_country_sent_cnt
    FROM email_cnt ec
    JOIN total_email te
      ON ec.country = te.country
  ),


  -- Combine account and email metrics using UNION ALL to align dimensions
  email_account AS (
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      account_cnt,
      0 AS sent_msg,
      0 AS open_msg,
      0 AS visit_msg,
      total_country_account_cnt,
      0 AS total_country_sent_cnt,
      rank_total_country_account_cnt,
      0 AS rank_total_country_sent_cnt
    FROM account_with_ranks
    UNION ALL
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      0 AS account_cnt,
      sent_msg,
      open_msg,
      visit_msg,
      0 AS total_country_account_cnt,
      total_country_sent_cnt,
      0 AS rank_total_country_account_cnt,
      rank_total_country_sent_cnt
    FROM email_with_ranks
  ),


  -- Aggregate the combined data and calculate Open Rate and CTR
  final_union AS (
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      sum(account_cnt) AS account_cnt,
      sum(sent_msg) AS sent_msg,
      sum(open_msg) AS open_msg,
      sum(visit_msg) AS visit_msg,
      max(total_country_account_cnt) AS total_country_account_cnt,
      max(total_country_sent_cnt) AS total_country_sent_cnt,
      max(rank_total_country_account_cnt) AS rank_total_country_account_cnt,
      max(rank_total_country_sent_cnt) AS rank_total_country_sent_cnt,
      round(safe_divide(sum(open_msg), sum(sent_msg)) * 100, 2)
        AS open_rate_pct,
      round(safe_divide(sum(visit_msg), sum(open_msg)) * 100, 2)
        AS click_to_open_rate_pct,
    FROM email_account
    GROUP BY 1, 2, 3, 4, 5
  )


-- Filter the final output to include only top 10 countries by accounts or emails
SELECT *
FROM final_union
WHERE
  (rank_total_country_account_cnt <= 10 AND rank_total_country_account_cnt > 0)
  OR (rank_total_country_sent_cnt <= 10 AND rank_total_country_sent_cnt > 0)
ORDER BY date, country
