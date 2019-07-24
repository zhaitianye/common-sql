-- 查询商家下商品是否有规格
SELECT
  m.name as 商家名称,
  mttr.item_id as 产品的id,
  mttr.name 产品名称,
  if(mttr.take_away_specification is not null,"有规格","无规格") as 当前产品是否有规格
FROM
  merchants AS m,
  merchants_taking_treats_rules AS mttr 
WHERE
  m.take_away_service = 1
  and m.language = 'hk'
  and mttr.language = 'hk'
  and m.random_id = mttr.merchant_random_id