-- Which industries and regions generated the highest revenue over the years?
SELECT
    industry,
    region,
    year,
    SUM(revenue_usd) AS total_revenue
FROM saas_financial_market_analysis
GROUP BY industry, region, year
ORDER BY total_revenue DESC;



-- What is the YoY revenue growth rate for each company?
select
	company,
	year,
round((revenue_usd - lag(revenue_usd) over (partition by company order by year))
/ nullif(lag(revenue_usd) over (partition by company order by year),0)*100,2) as yoy_growth_rate
from saas_financial_market_analysis
order by 1,2;


-- Which companies have the highest ARPU (Average Revenue Per User), and how does that compare across industries?
WITH industry_arpu_ranks AS (
    SELECT 
        industry,
        company,
        AVG(arpu_usd) AS avg_arpu_usd,
        RANK() OVER (PARTITION BY industry ORDER BY AVG(arpu_usd) DESC) as industry_rank
    FROM saas_financial_market_analysis
    WHERE arpu_usd IS NOT NULL
    GROUP BY industry, company
)
SELECT *
FROM industry_arpu_ranks
WHERE industry_rank = 1 
ORDER BY industry, avg_arpu_usd DESC;





--- Which companies have the best profit margins (Profit/Revenue)?
WITH profit_margins AS (
    SELECT 
        company,
        SUM(profit_usd) / NULLIF(SUM(revenue_usd), 0) AS profit_margin,
        RANK() OVER (ORDER BY (SUM(profit_usd) / NULLIF(SUM(revenue_usd), 0)) DESC) AS margin_rank
    FROM saas_financial_market_analysis
    WHERE profit_usd IS NOT NULL
      AND revenue_usd IS NOT NULL
    GROUP BY company
)
SELECT 
    company,
    ROUND(profit_margin * 100, 1) AS profit_margin_percent,
    margin_rank
FROM profit_margins
WHERE margin_rank = 1
ORDER BY profit_margin DESC;





-- Which industries show the highest expenses relative to revenue (burn rate)?
select
	industry,
	round( (sum(expenses_usd) / nullif(sum(revenue_usd), 0)) * 100, 2) as burn_rate_percent
from saas_financial_market_analysis
group by 1
having sum(revenue_usd) > 0
order by burn_rate_percent desc;





-- Top 10 companies contributing the most profit globally.
with top_10_companies as(
select 
	company,
	sum(profit_usd) as profit,
	rank() over(order by sum(profit_usd) desc) as rnk_
from saas_financial_market_analysis
group by 1
)
select
	company,
	profit
from top_10_companies
where rnk_ <=10




-- What is the average churn rate across industries, and which industry suffers the most churn?

select
	industry,
	round(avg(churn_rate),2) avg_churn
from saas_financial_market_analysis
group by 1
order by 2 desc







-- How does churn rate correlate with revenue and profit?
WITH company_metrics AS (
    SELECT
        company,
        industry,
        AVG(churn_rate) AS avg_churn_rate,
        AVG(profit_usd) AS avg_profit,
        AVG(profit_usd) / NULLIF(AVG(revenue_usd), 0) AS avg_profit_margin
    FROM saas_financial_market_analysis
    GROUP BY 1,2
)
SELECT
    company,
    industry,
    avg_churn_rate,
    avg_profit,
    avg_profit_margin
FROM company_metrics
ORDER BY avg_churn_rate DESC;






-- Which regions/industries have the fastest customer growth?

SELECT
  region,
AVG(
      POWER(customer_count, 1 / NULLIF(year - founded_year, 0)) - 1
    ) as customer_growth
FROM saas_financial_market_analysis
GROUP BY 1
order by 2 desc





-- Top 5 regions with the highest SaaS market share concentration.
SELECT
    industry,
    SUM(market_share_percent) AS total_market_share,
    ROUND(SUM(market_share_percent), 2) || '%' AS market_share_percentage
FROM saas_financial_market_analysis
GROUP BY industry
ORDER BY total_market_share DESC;