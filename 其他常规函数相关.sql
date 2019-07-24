-- 聚合查询两个点之间的距离，以距离的远近排序
-- HAVING语句通常与GROUP BY语句联合使用，用来过滤由GROUP BY语句返回的记录集。
-- HAVING语句的存在弥补了WHERE关键字不能与聚合函数联合使用的不足。
SELECT
  *,
  (ST_Distance_Sphere (point (s.centroid_lng, s.centroid_lat),point(113.95085800,22.54286900) )) AS distance
from distribution_point as s
where 
 s.nDistributionCircleUid = '8B68D8B4-340B-4BF4-9D35-E847020FFA03'
ORDER BY distance ASC

-- json查询出来进行拼接
SELECT
  user_id,
  GROUP_CONCAT( JSON_OBJECT( 'name', firstname ) ) AS aaa 
FROM
  users 
GROUP BY
  user_id 
  LIMIT 1

SELECT
  -- CONCAT('[',GROUP_CONCAT(JSON_OBJECT( 'lowestDiscount', lowestDiscount )),']') AS JSON
  JSON_OBJECT( 'uid', uid,'lowestDiscount', lowestDiscount,'highestDiscount',highestDiscount ) AS JSON
FROM
  merchant_discount_rules as mdr
where
  mdr.nStatus <> -1
  and mdr.merchant_random_id = 'JUY2UOQV'
GROUP BY
  uid