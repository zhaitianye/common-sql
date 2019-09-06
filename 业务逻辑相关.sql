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
  take_away_service,
  img_url_temp
FROM
  merchants_taking_treats_rules
WHERE
  merchant_id = 114
  and language = 'en'
  and valid = 1
  
SELECT DISTINCT
  id,
  item_id,
  name,
  price,
  denomination,
  cost,
  take_away_service,
  img_url_temp
FROM
  merchants_taking_treats_rules
WHERE
  merchant_id = 114
  and language = 'hk'
  and valid = 1


-- 把一个表的数据查询出来插入另外一个表，先select看是否可用，可用之后#号去掉插入
# INSERT INTO images (target,target_id,url,sequence,valid)
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


-- 查询商家商户的绑定情况
SELECT
  u.user_id as '用户ID',
  u.merchant_id as '商家ID',
  m.name as '商家名称',
  u.firstname as '用户名称',
  IF((u.wechat_id is null or u.wechat_id = ''),'不拥有','拥有') as 是否拥有微信ID,
  IF(u.wechat_oc_id is not null,'拥有','不拥有') as 是否拥有微信公众号ID,
  IF(u.wechat_union_id is not null,'拥有','不拥有') as 是否拥有微信全平台ID,
  IF(u.wechat_binded = 1,'已绑定','未绑定') as 是否绑定了微信
FROM
  users as u,
  merchants as m
WHERE
  m.merchant_id = u.merchant_id
  and m.language = 'hk'
and
  u.type = 2 
ORDER BY
  商家ID


-- 二维码相关的- 查询所有没有使用的公众号二维码
SELECT
  * 
FROM
  qrcode_recording as qr
WHERE 
  qr.nType = 2
  AND qr.nStatus = 0

-- 查询所有一些没有使用的公众号二维码
SELECT
  qr.nid,
  qr.sFunction,
  qr.sNameCh,
  qr.merchant_id,
  qr.merchant_random_id,
  qr.nStatus,
  qr.vDesc,
  qr.url
FROM
  qrcode_recording as qr
WHERE 
  qr.nType = 2
  AND qr.nStatus = 0
  Limit 50

-- 查询我们服务的所有商家
SELECT 
  *
FROM
  merchants as m
WHERE
  m.language = 'hk'
  and m.merchant_id >44

-- 查询可以导出到excel的二维码数据
SELECT 
  qr.nid as 二维码识别ID,
  CASE qr.sFunction WHEN 'watery' THEN '水牌' WHEN 'poster' THEN '海报' ELSE '未知' END as 二维码类型,
  qr.sNameCh as 商家名称,
  qr.vDesc AS 二维码状态,
  qr.url as 二维码地址,
  m.logo_url as 商家LOGO图片地址
FROM
  merchants as m,
  qrcode_recording as qr
WHERE
  m.language = 'hk'
  and m.merchant_id >44
  and m.random_id = qr.merchant_random_id
  and qr.nStatus = 1
  and qr.sFunction = 'poster'

-- 爆品相关的查询
SELECT
  mttr.id,
  mttr.item_id,
  mttr.name,
  mttr.price,
  mttr.denomination,
  mttr.cost,
  mttr.isTop,
  mttr.isHotSale,
  mttr.take_away_service,
  mttr.xTag,
  mttr.weight
FROM
  merchants_taking_treats_rules as mttr
WHERE 
    mttr.merchant_id = 72

-- 给一个商户生成商家登录账户
-- SELECT * FROM users where type =2 ORDER BY provider_id desc
-- provider_id 查询用户表，手动加1，random_id 用下面生成,其他数据使用最新的
-- Date.now().toString(36).toUpperCase();
INSERT INTO 
  users 
SET type=2, 
    provider_id=182, 
    merchant_id=100, 
    random_id='JZWBKUVB', 
    firstname = '鼎厨', 
    profile_url='https://images.usinno.cn/1566552257622_tkar.jpg', 
    phone_country_code='86', 
    phone_number='15999678365', 
    password='8365';

-- 修改前台显示商品说明文案的换行的问题
UPDATE merchants_taking_treats_rules 
SET usage_notes = '1. 仅限到店兑换使用。 \n2. 可兑换店里同价位产品，高于此面值产品需补差价。 \n3. 此礼品券不支持找零或折现。'
WHERE id in (3741,3742,3743,3744,3745,3746,3747,3748,3749,3750,3751,3752,3753,3754,3755,3756,3757,3758,3759,3760,3761,3762,3763,3764,3765,3766,3767,3768,3769,3770,3771,3772,3773,3774,3775,3776,3777,3778,3779,3780,3781,3782,3783,3784,3785,3786,3787,3788,3789,3790,3791,3792,3793,3794,3795,3796,3797,3798,3799,3800,3801,3802,3803,3804,3805,3806,3807,3808,3809,3810,3811,3812,3813,3814,3815,3816,3817,3818,3819,3820,3821,3822,3823,3824,3825,3826,3827,3828,3829,3830,3831,3832,3833,3834,3835,3836,3837,3838,3839,3840,3841,3842,3843,3844,3845,3846,3847,3848,3849,3850,3851,3852,3853,3854,3855,3856,3857,3858,3859,3860,3861,3862,3863,3864)