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

-- 查询外卖队列表的时间在这个月的开始和结束，外卖队列表和订单表，订单详情相连，订单详情下的上商家随机id为几个，然后进行分组
SELECT
  t.merchant_random_id, 
  count(t.treat_id) as count
FROM
  merchants_delivery_queue as mdq,
  charge as c,
  treats as t
WHERE
  mdq.sCharge_id = c.charge_id
  AND c.charge_id = t.charge_id
  AND t.merchant_random_id in ( 'JXHDRYEK', 'JUY2UOQV', 'JWI3MB8T')
  AND c.charge_source = 'take_out_bus'
  AND c.paid_success = 1
  AND date_add( mdq.dSpecifiedOfServiceTime, INTERVAL 8 HOUR ) > '2019-07-01 00:00:00' 
  AND date_add( mdq.dSpecifiedOfServiceTime, INTERVAL 8 HOUR ) <= '2019-07-31 23:59:59'
GROUP BY t.merchant_random_id


-- JOSN查询一些相关的聚合，弃用
SELECT
  c.charge_id,
  c.pipeline_number,
  m.id,
  m.merchant_id,
  m.random_id,
  m.name,
  m.logo_url,
  m.address,
  (SELECT
    CONCAT('[',GROUP_CONCAT(JSON_OBJECT( 'charge_id', t.charge_id, 'treat_id', t.treat_id, 'name', mttr.name, 'xSpecification', t.xSpecification )),']') AS JSON
  FROM
    treats as t,
    merchants_taking_treats_rules as mttr
  where
    t.charge_id = c.charge_id
    AND t.item_id = mttr.item_id
    AND t.merchant_random_id = mttr.merchant_random_id
    AND mttr.language = 'hk'
  GROUP BY
    t.charge_id) as treats
FROM
  charge AS c,
  treats as t,
  merchants as m
WHERE
  c.charge_id IN (
    'ch9FwUynjAzmSwh',
    'chPtGGklhR7gG2Q',
    'chOt5V629ryEc8g',
    'ch0jk7mgj9aWai5',
    'ch8l0zQU9zjUn4x',
    'chxWTbi1dwblTVw',
    'chny2Dml3HINWTd',
    'chgHshZyfACgSbz',
    'chuTnETgh46yUEV',
    'chjwolParSclK9j',
    'chcGYB3B25lYjVO',
    'chVYbgoWxxsOJfI',
    'chGPtxHIMiFjSzx',
    'ch6EeVUFV11DFYf',
    'chjcwQxi18TUEda',
    'chiqODPvpXW9UgD',
  'chx7mQTa4wMQz0n' 
  )
  AND c.charge_id = t.charge_id
  AND m.merchant_id = (
    SELECT t.merchant_id FROM treats as t where  t.charge_id = c.charge_id LIMIT 1
  )
  AND m.language = 'hk'
ORDER BY m.name asc, m.id asc


-- 查询一个特定商家的商品相关的
SELECT
  m.name as 商家名称,
  mttr.item_id as 产品的id,
  m.random_id as 商家随机id,
  mttr.name 产品名称,
  mttr.take_away_specification as 规格,
  (SELECT i.url FROM images as i where i.target = 10 and i.target_id = mttr.id and i.valid = 1 ORDER BY i.images_id LIMIT 1) as 图片地址
FROM
  merchants AS m,
  merchants_taking_treats_rules AS mttr 
WHERE
  m.language = 'hk'
  and mttr.language = 'hk'
  and m.random_id = mttr.merchant_random_id
  and m.merchant_id = 83

--//// 二
SELECT DISTINCT
  id,
  item_id,
  name,
  price,
  denomination,
  cost,
  take_away_service
FROM
  merchants_taking_treats_rules
WHERE
  merchant_id = 58
  and language = 'en'
  and valid = 1
  
SELECT DISTINCT
  id,
  item_id,
  name,
  price,
  denomination,
  cost,
  take_away_service
FROM
  merchants_taking_treats_rules
WHERE
  merchant_id = 58
  and language = 'hk'
  and valid = 1


-- 把一个表的数据查询出来插入另外一个表
INSERT INTO images (target,target_id,url,sequence,valid)
SELECT
  (10) as target,
  mttr.id as target_id,
  CONCAT('https://images.usinno.cn/000_merchant_product_image/houhaixiaoqu/huangshulangjibao/',mttr.img_url_temp) as url,
  (1) as sequence,
  (1) as valid
FROM
  merchants_taking_treats_rules as mttr
WHERE
  merchant_id = 95


-- 查询并更新一个商家的所有产品的规格
-- 用notlike去过滤看有多少种规格
-- 用update去逐条更新规则
SELECT
  mttr.id,
  mttr.merchant_id,
  mttr.take_away_specification
FROM
  merchants_taking_treats_rules  as mttr
WHERE
  mttr.merchant_id = 47

AND mttr.take_away_specification NOT like '[{"name": "温度", "isFees": false, "children": [{"name": "正常冰", "active": true}, {"name": "少冰"}, {"name": "热"}], "minimumCount": 1, "multipleCount": 1}, {"name": "甜度", "isFees": false, "children": [{"name": "正常糖", "active": true}, {"name": "少糖", "active": true}], "minimumCount": 1, "multipleCount": 1}]'

-- 查询一个商家下面的所有不重复的规格
SELECT 
  DISTINCT
  mttr.take_away_specification,
  mttr.merchant_id
FROM
  merchants_taking_treats_rules  as mttr
WHERE
  mttr.merchant_id = 69


-- 更新一个商家下的一个指定的规格
UPDATE merchants_taking_treats_rules 
SET 
  take_away_specification = ''
WHERE 
  merchant_id = 47
AND mttr.take_away_specification like '[{"name": "温度", "isFees": false, "children": [{"name": "正常冰", "active": true}, {"name": "少冰"}, {"name": "热"}], "minimumCount": 1, "multipleCount": 1}, {"name": "甜度", "isFees": false, "children": [{"name": "正常糖", "active": true}, {"name": "少糖", "active": true}], "minimumCount": 1, "multipleCount": 1}]'