-- Which industries and regions generated the highest revenue over the years?
select
	distinct(industry),
	region,
	revenue_usd,
	year
from saas_financial_market_analysis
order by 3 desc
