Схема БД состоит из четырех таблиц:
Product(maker, model, type)
PC(code, model, speed, ram, hd, cd, price)
Laptop(code, model, speed, ram, hd, price, screen)
Printer(code, model, color, type, price)

Таблица Product представляет производителя (maker),
номер модели (model) и тип ('PC' - ПК, 'Laptop' - ПК-блокнот или 'Printer' - принтер). 

Предполагается, что номера моделей в таблице Product уникальны для всех производителей 
и типов продуктов. 

В таблице PC для каждого ПК, однозначно определяемого уникальным кодом – code,
указаны модель – model (внешний ключ к таблице Product), 
скорость - speed (процессора в мегагерцах), объем памяти - ram (в мегабайтах), 
размер диска - hd (в гигабайтах), скорость считывающего устройства - cd (например, '4x') 
и цена - price. 

Таблица Laptop аналогична таблице РС за исключением того, 
что вместо скорости CD содержит размер экрана -screen (в дюймах). 

В таблице Printer для каждой модели принтера указывается, является ли он 
цветным - color ('y', если цветной), тип принтера - type (лазерный – 'Laser', 
струйный – 'Jet' или матричный – 'Matrix') и цена - price.

select * from product

maker model type
A 1232  PC
A 1233  PC
A 1276  Printer
A 1298  Laptop
A 1401  Printer
A 1408  Printer
A 1752  Laptop
B 1121  PC
B 1750  Laptop
C 1321  Laptop
D 1288  Printer
D 1433  Printer
E 1260  PC
E 1434  Printer
E 2112  PC
E 2113  PC

select * from product
select * from pc
select * from printer
select * from laptop


Задание: 147 (Serge I: 2011-02-11)

Пронумеровать строки из таблицы Product в следующем порядке: 
имя производителя в порядке убывания числа производимых им моделей 
(при одинаковом числе моделей имя производителя в алфавитном порядке по возрастанию), 
номер модели (по возрастанию).
Вывод: номер в соответствии с заданным порядком, имя производителя (maker), модель (model) 


select maker, model from product

/*
no  MAKER MODEL
10  E 2112
11  E 2113
12  B 1121
13  B 1750
14  D 1288
15  D 1433
16  C 1321
1 A 1232
2 A 1233
3 A 1276
4 A 1298
5 A 1401
6 A 1408
7 A 1752
8 E 1260
9 E 1434
*/


Задание: 146 (Serge I: 2008-08-30)

Для ПК с максимальным кодом из таблицы PC вывести все его характеристики (кроме кода) в два столбца:
- название характеристики (имя соответствующего столбца в таблице PC);
- значение характеристики

with source1 as
(
select code, 
       model, 
       speed, 
       ram, 
       hd, 
       cd,
       price 
from pc 
where code=(select max(code) from pc)
)
select 'model' as chr1, to_char(model) as value from source1
union all
select 'speed' as chr1, to_char(speed) as value from source1
union all
select 'ram' as chr1, to_char(ram) as value from source1
union all
select 'hd' as chr1, to_char(hd) as value from source1
union all
select 'cd' as chr1, to_char(cd) as value from source1
union all
select 'price' as chr1, to_char(price) as value from source1

/*
CHR	VALUE
cd	50x
hd	20
model	1233
price	970
ram	128
speed	800
*/


Задание: 144 (Serge I: 2019-01-04)

Найти производителей, которые производят PC как с самой низкой ценой, так и с самой высокой.
Вывод: maker

with tmp as
(
select maker, min(price) minp, max(price) maxp from product p, pc
where p.model=pc.model
group by maker
) select maker from tmp t 
  where t.minp=(select min(tt.minp) from tmp tt)   
        and t.maxp=(select max(tt.maxp) from tmp tt)


Задание: 137 (Serge I: 2005-01-19)

Для каждой пятой модели (в порядке возрастания номеров
моделей) из таблицы Product
определить тип продукции и среднюю цену модели.


select mod5.type, avg(price) from
(
select rn, maker, model, type
from 
(
select row_number() over(order by model) rn,
       maker, 
       model, 
       type 
from Product p
) where mod(rn,5)=0
) mod5,
(
select 'Printer' type, pr.model, pr.price from printer pr
union all
select 'Laptop' type, l.model, l.price from laptop l
union all
select 'PC' type, pc.model, pc.price from pc
) tm where mod5.type=tm.type(+) and mod5.model=tm.model(+)
group by mod5.type, mod5.model

/*
TYPE	AVG_PRICE
PC	
Printer	270
Printer	400
*/


Задание: 127 (qwrqwr: 2015-04-24)

Найти округленное до сотых долей среднее арифметическое следующих цен:
1. Цена самых дешевых Laptop-ов от производителей РС с самой низкой скоростью CD;
2. Цена самых дорогих РС от производителей самых дешевых принтеров;
3. Цена самых дорогих принтеров от производителей Laptop-ов с наибольшим объемом памяти.
Замечание: При расчёте среднего отсутствующие цены не учитывать.


with lap as
 (select l.model, l.price
    from laptop l, product p
   where l.model = p.model
     and p.maker in (select distinct maker
                       from product p, pc pc1
                      where p.type = 'PC'
                        and p.model = pc1.model
                        and to_number(substr(cd,1,instr(cd,'x')-1)) = 
                        (select min(to_number(substr(cd,1,instr(cd,'x')-1))) from pc))),
pcc as
 (select pc.model, pc.price
    from pc, product p
   where pc.model = p.model
     and p.maker in
         (select distinct maker
            from product p, printer pr
           where p.type = 'Printer'
             and p.model = pr.model
             and pr.price = (select min(price) from printer))),
pri as
 (select pr.model, pr.price
    from printer pr, product p
   where pr.model = p.model
     and p.maker in
         (select distinct maker
            from product p, laptop l
           where p.type = 'Laptop'
             and p.model = l.model
             and l.ram = (select max(ram) from laptop)))
select round(avg(summa), 2) AVG_VAL
  from (select sum(lap.price) summa
          from lap
         where lap.price in (select min(price) from lap)
        union all
        select sum(pcc.price) summa
          from pcc
         where pcc.price in (select max(price) from pcc)
        union all
        select sum(pri.price) summa
          from pri
         where pri.price in (select max(price) from pri))

/*
AVG_VAL
693.33
*/
select cd, instr(cd,'x'), to_number(substr(cd,1,instr(cd,'x')-1)) from pc


Задание: 125 (Baser: 2014-10-24)

Данные о продаваемых моделях и ценах (из таблиц Laptop, PC и Printer) объединить 
в одну таблицу LPP и создать в ней порядковую нумерацию (id) без пропусков и дубликатов.
Считать, что модели внутри каждой из трёх таблиц упорядочены по возрастанию поля code. 
Единую нумерацию записей LPP сделать по следующему правилу: сначала идут первые модели 
из таблиц (Laptop, PC и Printer), потом последние модели, далее - вторые модели из таблиц, 
предпоследние и т.д.
При исчерпании моделей определенного типа, нумеровать только оставшиеся модели других типов.
Вывести: id, type, model и price. Тип модели type является строкой 'Laptop', 'PC' или 'Printer'.


with tmp1 as
 (select code,
         'Laptop' type,
         model,
         price,
         case
           when code <= (select count(*) from laptop) / 2 then
            row_number() over(order by code) * 2 - 1
           else
            row_number() over(order by code desc) * 2
         end num
    from laptop
  union
  select code,
         'PC' type,
         model,
         price,
         case
           when code <= (select count(*) from pc) / 2 then
            row_number() over(order by code) * 2 - 1
           else
            row_number() over(order by code desc) * 2
         end num
    from pc
  union
  select code,
         'Printer' type,
         model,
         price,
         case
           when code <= (select count(*) from printer) / 2 then
            row_number() over(order by code) * 2 - 1
           else
            row_number() over(order by code desc) * 2
         end num
    from printer)
select row_number() over(order by num, type) id, type, model, price
  from tmp1



with lpp as
(
select code, 'PC' type, model, price from pc
union
select code, 'Printer' type, model, price from printer
union
select code, 'Laptop' type, model, price from laptop
) 
select code, 
       max(code) over (partition by type) max_type_code id
       --(max(code) over (partition by type)) - (row_number() over (order by type, code)) + 1 eee,
       --row_number() over (order by type, code) rn_code_type,
       --row_number() over (order by type, code desc) rn_code_type_desk,
       --first_value(code) over (order by type) first_code_type,
       --last_value(code) over (order by  type) last_code_type,
       --max(code) over (partition by type) max_type_code,
       --min(code) over (partition by type) min_type_code,       
       --min(code) over (partition by type) min_type_code,       
       type, 
       model, 
       price 
from lpp

1,6,2,5,3,4

/*
ID  type  MODEL   PRICE
10  Laptop  1752  1150
11  PC  1233  980
12  Printer   1408  270
13  Laptop  1750  1200
14  PC  1233  600
15  Printer   1434  290
16  Laptop  1298  1050
17  PC  1260  350
18  Printer   1401  150
19  PC  1121  850
1   Laptop  1298  700
20  PC  1232  350
21  PC  1121  850
22  PC  1232  350
23  PC  1233  950
24  PC  1232  400
2   PC  1232  600
3   Printer   1276  400
4   Laptop  1298  950
5   PC  1233  970
6   Printer   1288  400
7   Laptop  1321  970
8   PC  1121  850
9   Printer   1433  270
*/

Задание: 123 (qwrqwr: 2014-11-07)

Для каждого производителя подсчитать: сколько имеется в наличии его продуктов 
(любого типа) с неуникальной для этого производителя ценой и количество таких неуникальных цен.
Вывод: производитель, количество продуктов, количество цен. 

Подcказки к задаче №123
Необходимо подсчитывать продукты, а не модели.

select m1.maker, nvl(cou,0) cou, nvl(cou2,0) cou2 from
(
select maker from product
group by maker
) m1,
(
select maker, sum(cnt) cou, COUNT(cnt) cou2 from
(
--Неуникальные цены и количество моделей с неуникальной 
--ценой для каждого из производителей
select maker, price, count(*) cnt from 
(
select p.maker, pc.price from product p, pc
where p.model=pc.model(+) 
      and p.type='PC'
union all
select p.maker, pr.price from product p, printer pr
where p.model=pr.model(+) 
      and p.type='Printer'
union all
select p.maker, l.price from product p, laptop l
where p.model=l.model(+) 
      and p.type='Laptop'
)      
group by maker, price
having count(price)>1)
group by maker
) m2     
where m1.maker=m2.maker(+)




WITH dsM1 AS
 (--все модели и их цены
  SELECT model, price
    FROM PC
  UNION ALL
  SELECT model, price
    FROM Laptop
  UNION ALL
  SELECT model, price
    FROM Printer),
dsP AS
 (--Соединяем с производителями
  SELECT p.maker, p.model, dsM1.price
    FROM Product p
    left join dsM1
      on dsM1.model = p.model)
select * from dsP
,
dsPrice AS
 (SELECT maker,
         (SELECT case when COUNT(dsP1.price) > 1 then 1 else 0 end
            FROM dsP dsP1
           WHERE dsP1.price = dsP.price
             and dsP1.maker = dsP.maker) c,
         price
    FROM dsP)
select * from dsPrice    
SELECT maker, sum(c) cou, COUNT(DISTINCT 
       case when c > 0 then price else null end
       ) cou2
  FROM dsPrice
 GROUP BY maker



/*
MAKER   COU   COU2
A   8   4
B   3   1
C   0   0
D   0   0
E   0   0
*/



Задание: 105 (qwrqwr: 2013-09-11)

Статистики Алиса, Белла, Вика и Галина нумеруют строки у таблицы Product.
Все четверо упорядочили строки таблицы по возрастанию названий производителей.
Алиса присваивает новый номер каждой строке, строки одного производителя она упорядочивает по номеру модели.
Трое остальных присваивают один и тот же номер всем строкам одного производителя.
Белла присваивает номера начиная с единицы, каждый следующий производитель увеличивает номер на 1.
У Вики каждый следующий производитель получает такой же номер, какой получила бы первая модель этого производителя у Алисы.
Галина присваивает каждому следующему производителю тот же номер, который получила бы его последняя модель у Алисы.
Вывести: maker, model, номера строк получившиеся у Алисы, Беллы, Вики и Галины соответственно.


select
  maker,
  model,
  row_number() over (order by maker, model) as a,
  dense_rank() over (order by maker) as b,
  rank() over (order by maker) as c,
  count(*) over (order by maker) as d
from product


select pA.maker,
       pA.model,
       pA.A A,
       pB.B B,
       first_value(pA.A) over(partition by pA.maker order by pA.A asc) C,
       first_value(pA.A) over(partition by pA.maker order by pA.A desc) D
  from (select maker, model, row_number() over(order by maker, model) A
          from product) pA,
       (select maker, row_number() over(order by maker) B
          from product
         group by maker) pB
 where pA.Maker = pB.Maker
 order by pA.maker, pA.model


with productA as
(
select maker,
       model,
       row_number() over(order by maker, model) A
  from product 
 order by maker, model
), 
productB as
(select maker, row_number() over(order by maker) B
          from product
         group by maker)
select pA.maker,
       pA.model,
       pA.A A,
       pB.B B,
       first_value(pA.A) over (partition by pA.maker order by pA.A asc) C,
       first_value(pA.A) over (partition by pA.maker order by pA.A desc) D       
  from productA pA,
       productB pB
 where pA.Maker = pB.Maker
 order by pA.maker, pA.model
         
         
--,productC as         
select pA.maker,
       pA.model,
       pA.A A,
       first_value(pA.A) over (partition by maker order by A asc) C,
       first_value(pA.A) over (partition by maker order by A desc) D
  from productA pA



select pA.maker,
       pA.model,
       row_number() over(order by pA.maker, pA.model) A,
       pB.B B,
       first_value(A) over (partition by maker order by A asc) C,
       last_value(A) over (partition by maker order by A asc) D
  from product pA,
       (select maker, row_number() over(order by maker) B
          from product
         group by maker) pB
 where pA.Maker = pB.Maker
 order by pA.maker, pA.model

select maker, 
       row_number() over(order by maker) B 
from product pB 
group by maker


/*
maker model A B C D
A 1232  1 1 1 7
A 1233  2 1 1 7
A 1276  3 1 1 7
A 1298  4 1 1 7
A 1401  5 1 1 7
A 1408  6 1 1 7
A 1752  7 1 1 7
B 1121  8 2 8 9
B 1750  9 2 8 9
C 1321  10  3 10  10
D 1288  11  4 11  12
D 1433  12  4 11  12
E 1260  13  5 13  16
E 1434  14  5 13  16
E 2112  15  5 13  16
E 2113  16  5 13  16
*/

Задание: 101 (qwrqwr: 2013-03-29)

Таблица Printer сортируется по возрастанию поля code.
Упорядоченные строки составляют группы: первая группа начинается с первой строки, 
каждая строка со значением color='n' начинает новую группу, группы строк не перекрываются.
Для каждой группы определить: наибольшее значение поля model (max_model), 
количество уникальных типов принтеров (distinct_types_cou) и среднюю цену (avg_price).
Для всех строк таблицы вывести: code, model, color, type, price, max_model, distinct_types_cou, avg_price.



select code, 
       model, 
       color, 
       type, 
       price,
       max(model) over (partition by grp_num) max_model,
       count(distinct type) over (partition by grp_num) distinct_types_cou,
       avg(price) over (partition by grp_num) avg_price
from 
(
--Разбить на группы
select p1.*,
      (SELECT count(p2.color) FROM printer p2 where p2.code<=p1.code and p2.color='n') grp_num
from printer p1 
order by code
)
order by code

Задание: 98 (qwrqwr: 2010-04-26)

Вывести список ПК, для каждого из которых результат побитовой операции ИЛИ, 
примененной к двоичным представлениям скорости процессора и объема памяти, 
содержит последовательность из не менее четырех идущих подряд единичных битов.
Вывод: код модели, скорость процессора, объем памяти.


with ctebins (code,speed,ram,speed_w_level,speed_binval,ram_w_level,ram_binval) as
 (select code,
         speed,
         ram,
         speed as speed_w_level,
         cast('' as varchar2(4000)) as speed_binval,
         ram as ram_w_level,
         cast('' as varchar2(4000)) as ram_binval
    from pc
  union all
  select code,
         c.speed,
         c.ram,
         trunc(c.speed_w_level / 2),-- as speed_w_level,
         cast(mod(speed_w_level,2) as varchar2(1)) || speed_binval,-- as speed_binval 
         trunc(c.ram_w_level / 2),-- as ram_w_level,
         cast(mod(ram_w_level,2) as varchar2(1)) || ram_binval-- as speed_binval 
    from ctebins c
   where c.speed_w_level > 0),
res1 as   
(select code, speed, ram, speed_binval, ram_binval from ctebins where speed_w_level = 0)
--select * from res1
,
res2 as
(
select code, 
       lpad(speed_binval,30,'0') speed_binval, 
       lpad(ram_binval,30,'0') ram_binval
from res1         
)
--select * from res2
, 
res3 as
(   
select code,
       speed_binval, 
       ram_binval,
       case when substr(speed_binval, 1, 1)='1' or  substr(ram_binval, 1, 1)='1' then '1' else '0' end ||
       case when substr(speed_binval, 2, 1)='1' or  substr(ram_binval, 2, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 3, 1)='1' or  substr(ram_binval, 3, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 4, 1)='1' or  substr(ram_binval, 4, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 5, 1)='1' or  substr(ram_binval, 5, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 6, 1)='1' or  substr(ram_binval, 6, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 7, 1)='1' or  substr(ram_binval, 7, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 8, 1)='1' or  substr(ram_binval, 8, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 9, 1)='1' or  substr(ram_binval, 9, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 10, 1)='1' or  substr(ram_binval, 10, 1)='1' then '1' else '0' end ||
       case when substr(speed_binval, 11, 1)='1' or  substr(ram_binval, 11, 1)='1' then '1' else '0' end ||
       case when substr(speed_binval, 12, 1)='1' or  substr(ram_binval, 12, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 13, 1)='1' or  substr(ram_binval, 13, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 14, 1)='1' or  substr(ram_binval, 14, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 15, 1)='1' or  substr(ram_binval, 15, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 16, 1)='1' or  substr(ram_binval, 16, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 17, 1)='1' or  substr(ram_binval, 17, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 18, 1)='1' or  substr(ram_binval, 18, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 19, 1)='1' or  substr(ram_binval, 19, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 20, 1)='1' or  substr(ram_binval, 20, 1)='1' then '1' else '0' end ||    
       case when substr(speed_binval, 21, 1)='1' or  substr(ram_binval, 21, 1)='1' then '1' else '0' end ||
       case when substr(speed_binval, 22, 1)='1' or  substr(ram_binval, 22, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 23, 1)='1' or  substr(ram_binval, 23, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 24, 1)='1' or  substr(ram_binval, 24, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 25, 1)='1' or  substr(ram_binval, 25, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 26, 1)='1' or  substr(ram_binval, 26, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 27, 1)='1' or  substr(ram_binval, 27, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 28, 1)='1' or  substr(ram_binval, 28, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 29, 1)='1' or  substr(ram_binval, 29, 1)='1' then '1' else '0' end ||  
       case when substr(speed_binval, 30, 1)='1' or  substr(ram_binval, 30, 1)='1' then '1' else '0' end bit_or    
         
  from res2
) select pc.code, pc.speed, pc.ram 
  from res3, pc
  where res3.code=pc.code
        and bit_or like '%1111%'
  


     
select code,
       1 as num_pp,
       substr(speed_binval, 1, 1) sb,
       substr(ram_binval, 1, 1) rb
  from res2
union
select code,
       2 as num_pp,
       substr(speed_binval, 2, 1) sb,
       substr(ram_binval, 2, 1) rb
  from res2
union
select code,
       3 as num_pp,
       substr(speed_binval, 3, 1) sb,
       substr(ram_binval, 3, 1) rb
  from res3
union
select code,
       4 as num_pp,
       substr(speed_binval, 4, 1) sb,
       substr(ram_binval, 4, 1) rb
  from res3




--19
--10011

19/2 = 9 с остатком 1
9/2 = 4 c остатком 1
4/2 = 2 без остатка 0
2/2 = 1 без остатка 0
1/2 = 0 с остатком 1

select 19 as num, 
       mod(19,2) b1, 
       trunc(19/2),
       mod(trunc(19/2),2) b2 
from dual        


select code,
       speed,
       ram,
       
  from pc



with ctebins (code,speed,ram,speed_w_level,speed_binval,ram_w_level,ram_binval) as
 (select code,
         speed,
         ram,
         speed as speed_w_level,
         cast('' as varchar2(4000)) as speed_binval,
         ram as ram_w_level,
         cast('' as varchar2(4000)) as ram_binval
    from pc
  union all
  select code,
         c.speed,
         c.ram,
         trunc(c.speed_w_level / 2),-- as speed_w_level,
         cast(mod(speed_w_level,2) as varchar2(1)) || speed_binval,-- as speed_binval 
         trunc(c.ram_w_level / 2),-- as ram_w_level,
         cast(mod(ram_w_level,2) as varchar2(1)) || ram_binval-- as speed_binval 
    from ctebins c
   where c.speed_w_level > 0)
select code, speed, ram, speed_binval, ram_binval from ctebins where speed_w_level = 0;


with function to_base(p_dec in number,
p_base in number) return varchar2 is l_str varchar2(255) default NULL;
l_num number default p_dec;
l_hex varchar2(16) default '0123456789ABCDEF';
begin
  if (p_dec is null or p_base is null) then
    return null;
  end if;
  if (trunc(p_dec) <> p_dec OR p_dec < 0) then
    raise PROGRAM_ERROR;
  end if;
  loop
    l_str := substr(l_hex, mod(l_num, p_base) + 1, 1) || l_str;
    l_num := trunc(l_num / p_base);
    exit when(l_num = 0);
  end loop;
  return l_str;
end;
q1 as
(
select code,
       speed,
       ram,
       to_base(speed, 2) speed_bin,
       to_base(ram, 2) ram_bin
  from pc
) select * from q1

111110100
  1000000


CODE  SPEED_ORIG  SPEED_BINVAL
1 500 111110100
2 750 1011101110
3 500 111110100
4 600 1001011000
5 600 1001011000
6 750 1011101110
7 500 111110100
8 450 111000010
9 450 111000010
10  500 111110100
11  900 1110000100
12  800 1100100000

  
/*
code  speed ram
10  500 32
1 500 64
3 500 64
7 500 32
9 450 32
*/

select * from pc

WITH TEMP AS 
(SELECT code, 
       speed,
       ram,
       speed|ram AS ILI,
       speed|ram*1 AS Working_level,
       CAST('' AS VARCHAR(max)) AS Bi_ILI FROM PC
 UNION ALL
 SELECT TEMP.code,
       TEMP.speed,
       TEMP.ram,
       TEMP.ILI,
       TEMP.Working_level / 2,
       CAST(TEMP.Working_level%2 AS VARCHAR(max))+TEMP.Bi_ILI FROM TEMP
 WHERE TEMP.Working_level> 0 
)
SELECT code, speed, ram FROM TEMP
       WHERE Working_level=0
       AND Bi_ILI like '%1111%' 


with CTE AS
 (select 1 n, cast(0 as varchar(16)) bit_or, code, speed, ram
    FROM PC
  UNION ALL
  select n * 2,
         cast(convert(bit, (speed | ram) /*&*/n) as varchar(1)) +
         cast(bit_or as varchar(15)),
         code,
         speed,
         ram
    from CTE
   where n < 65536)
select code, speed, ram
  from CTE
 where n = 65536
   and CHARINDEX('1111', bit_or) > 0

Задание: 97 (qwrqwr: 2013-02-15)

Отобрать из таблицы Laptop те строки, для которых выполняется следующее условие:
значения из столбцов speed, ram, price, screen возможно расположить таким образом, 
что каждое последующее значение будет превосходить предыдущее в 2 раза или более.
Замечание: все известные характеристики ноутбуков больше нуля.
Вывод: code, speed, ram, price, screen.

select code, speed from Laptop

WITH AAA AS
 (SELECT l.code id, l.speed a
    FROM Laptop l
   WHERE l.speed > 0
     and l.ram > 0
     and l.price > 0
     and l.screen > 0
  UNION
  SELECT l.code, l.ram
    FROM Laptop l
   WHERE l.speed > 0
     and l.ram > 0
     and l.price > 0
     and l.screen > 0
  UNION
  SELECT l.code, l.price
    FROM Laptop l
   WHERE l.speed > 0
     and l.ram > 0
     and l.price > 0
     and l.screen > 0
  UNION
  SELECT l.code, l.screen
    FROM Laptop l
   WHERE l.speed > 0
     and l.ram > 0
     and l.price > 0
     and l.screen > 0),
BBB AS
 (SELECT id, a, row_number() over(partition BY id ORDER BY a) r FROM AAA)
 --select * from bbb
,
CCC AS
 (SELECT BBB.id
    FROM BBB, BBB BBB1
   WHERE BBB.id = BBB1.id
     and BBB.r + 1 = BBB1.r
     and BBB.a * 2 <= BBB1.a
   GROUP BY BBB.id
  HAVING COUNT(*) = 3
  )
--select * from ccc
SELECT l.code, l.speed, l.ram, l.price, l.screen
  FROM CCC, Laptop l
 WHERE CCC.id = l.code

--MSSQL
select code, speed, ram, price, screen
  from laptop
 where exists (select 1 x
          from (select v, rank() over(order by v) rn
                  from (select cast(speed as float) sp,
                               cast(ram as float) rm,
                               cast(price as float) pr,
                               cast(screen as float) sc) l unpivot(v for c in(sp,
                                                                              rm,
                                                                              pr,
                                                                              sc)) u) l
        pivot(max(v)
           for rn in([ 1 ], [ 2 ], [ 3 ], [ 4 ])) p
         where [ 1 ] * 2 <= [ 2 ]
           and [ 2 ] * 2 <= [ 3 ]
           and [ 3 ] * 2 <= [ 4 ])

/*
CODE  SPEED RAM PRICE SCREEN
1 350 32  700 11
6 450 64  950 12
*/


Задание: 90 (Serge I: 2012-05-04)

Вывести все строки из таблицы Product, кроме трех строк с наименьшими номерами моделей и трех строк с наибольшими номерами моделей.


select *
  from Product
minus
select *
  from (--три строки с наименьшими номерами моделей
        select *
          from (select * from Product p order by model asc)
         where rownum < 4
        union all
        --три строки с наибольшими номерами моделей
        select *
          from (select * from Product p order by model desc)
         where rownum < 4)

Задание: 89 (Serge I: 2012-05-04)

Найти производителей, у которых больше всего моделей в таблице Product, а также тех, у которых меньше всего моделей.
Вывод: maker, число моделей

with max_min as
(
select maker, count(2) cnt_model, max(count(2)) over() max_cnt_model, min(count(2)) over() min_cnt_model
   from product
 group by maker
) 
select maker, cnt_model from max_min where cnt_model=max_cnt_model
union 
select maker, cnt_model from max_min where cnt_model=min_cnt_model

/*

MAKER QTY
A 7
C 1
*/

Задание: 86 (Serge I: 2012-04-20)

Для каждого производителя перечислить в алфавитном порядке с разделителем "/" все типы выпускаемой им продукции.
Вывод: maker, список типов продукции

with grp as
 (select maker, type from product p group by maker, type),
grp2 as
 (select maker,
         case
           when exists (select 1
                   from grp g2
                  where g2.maker = g1.maker
                    and g2.type = 'Laptop') then
            'Laptop'
           else
            ''
         end || 
         case
           when exists (select 1
                   from grp g2
                  where g2.maker = g1.maker
                    and g2.type = 'PC') then
            'PC'
           else
            ''
         end || 
         case
           when exists (select 1
                   from grp g2
                  where g2.maker = g1.maker
                    and g2.type = 'Printer') then
            'Printer'
           else
            ''
         end as typess
    from grp g1
   group by maker)
select maker, replace(replace(typess, 'pP', 'p/P'), 'CP', 'C/P') typesss
  from grp2
 order by maker


MAKER TYPES
A Laptop/PC/Printer
B Laptop/PC
C Laptop
D Printer
E PC/Printer


Задание: 85 (Serge I: 2012-03-16)

Найти производителей, которые выпускают только принтеры или только PC.
При этом искомые производители PC должны выпускать не менее 3 моделей.


select maker
  from product p
--Производители выпускающие только принтеры
 where not exists (select 1
          from product p1
         where p1.maker = p.maker
           and p1.type in ('Laptop', 'PC'))
   and exists (select 1
          from product p1
         where p1.maker = p.maker
           and p1.type = 'Printer')
union
--Производители выпускающие только PC
select maker
  from product p
 where 1 = 1
   and not exists (select 1
          from product p1
         where p1.maker = p.maker
           and p1.type in ('Laptop', 'Printer'))
   and exists (select 1
          from product p1
         where p1.maker = p.maker
           and p1.type = 'PC')
   and exists (select pr.maker from product pr 
      where pr.type='PC'
      and pr.maker = p.maker
      group by pr.maker
      having count(*) >=3)
         

/*
MAKER
D
*/


Задание: 82 (Serge I: 2011-10-08)

В наборе записей из таблицы PC, отсортированном по столбцу code (по возрастанию) найти среднее 
значение цены для каждой шестерки подряд идущих ПК.
Вывод: значение code, которое является первым в наборе из шести строк, среднее значение цены в наборе.


WITH CTE
AS
(
SELECT PC.code,PC.price, ROW_NUMBER() OVER (ORDER BY PC.code) as numb
FROM PC
)
SELECT C1.code, AVG(C2.price)
FROM CTE C1
JOIN CTE C2 ON (C2.numb-C1.numb)> =0 AND (C2.numb-C1.numb)<6  
GROUP BY C1.numb,C1.code
HAVING COUNT(C1.numb)=6


WITH CTE
AS
(
SELECT PC.code,PC.price, ROW_NUMBER() OVER (ORDER BY PC.code) as numb
FROM PC
)
SELECT C1.*, 
       C2.*,
       C2.numb-C1.numb 
       --AVG(C2.price)
FROM CTE C1
JOIN CTE C2 ON (C2.numb-C1.numb)<6 AND (C2.numb-C1.numb)> =0
--GROUP BY C1.numb,C1.code
--HAVING COUNT(C1.numb)=6

select code, model, price,  avg(price) over (partition by code*2 order by code) as AVGPR from PC p1

select p1.* from PC p1
order by code

/*
CODE	AVGPR?
1	783.333333333333333333333333333333333333
2	750
3	666.666666666666666666666666666666666667
4	625
5	541.666666666666666666666666666666666667
6	563.333333333333333333333333333333333333
7	566.666666666666666666666666666666666667
*/


Задание: 80 (Baser: 2011-11-11)
Найти производителей компьютерной техники, у которых нет моделей ПК, не представленных в таблице PC.

--Все производители
select maker from product p1
group by maker
minus
--Производители у которых есть модели ПК не представленные в таблице PC
select maker from product p1
where p1.type='PC'
and not exists (select * from PC p2 where p1.model=p2.model)
group by maker

/*
MAKER
A
B
C
D
*/



Задание: 71 (Serge I: 2008-02-23)
Найти тех производителей ПК, все модели ПК которых имеются в таблице PC.

select * from product p

--Уникальные модели в PC
select distinct model from pc

--Все модели всех производителей
select p.maker, p.model
from product p
where p.type='PC' 
group by p.maker, p.model



select distinct p.maker from product p where p.type = 'PC'
--Производители c моделями PC
minus 
select distinct maker from
--Производители, модели PC которых отсутствуют в таблице PC
(
--соединяем pr и mip лефтджоином
select pr.maker, pr.model, mip.model as mip_model
  from (
        --Все модели всех производителей  
        select p.maker, p.model
          from product p
         where p.type = 'PC'
         group by p.maker, p.model) pr,
       (--Уникальные модели в таблице PC
       select distinct model from pc) mip
 where pr.model = mip.model(+)
) where mip_model is null

Задание: 65 (Serge I: 2009-08-24)

Пронумеровать уникальные пары {maker, type} из Product, упорядочив их следующим образом:
- имя производителя (maker) по возрастанию;
- тип продукта (type) в порядке PC, Laptop, Printer.
Если некий производитель выпускает несколько типов продукции, то выводить его имя только в первой строке;
остальные строки для ЭТОГО производителя должны содержать пустую строку символов ('').

select num,
       CASE maker_num
         WHEN 1 THEN
          maker
         ELSE
          ''
       END maker,
       type
  from (select rownum num,
               maker,
               type,
               ROW_NUMBER() OVER(partition by maker ORDER BY rownum) AS maker_num
          from (select *
                  from (select maker,
                               type,
                               CASE type
                                 WHEN 'PC' THEN
                                  1
                                 WHEN 'Laptop' THEN
                                  2
                                 WHEN 'Printer' THEN
                                  3
                               END type_order
                          from product)
                 group by maker, type_order, type
                 order by maker, type_order, type))

Задание: 58 (Serge I: 2009-11-13)

Для каждого типа продукции и каждого производителя из таблицы Product c точностью до двух десятичных 
знаков найти процентное отношение числа моделей данного типа данного производителя к общему числу 
моделей этого производителя.
Вывод: maker, type, процентное отношение числа моделей данного типа к общему числу моделей производителя


select maker, 
       type, 
       --model,
       count(model) over(PARTITION BY maker, type order by maker, type) cnt_model_by_type_maker,
       count(model) over(PARTITION BY maker order by maker) cnt_model_by_type_maker
from product

select t4.maker, t4.type, nvl(t3.proc,0) proc
  from ( --Декартово произведение
        select pp.maker, tt.type
          from (select type from product group by type) tt,
                (select maker from product group by maker) pp) t4,
       ( --Основной запрос с вычислением процентов
        select t1.maker,
                t1.type,
                --t1.cnt_model_maker_type,
                --t2.cnt_model_maker,
                round((t1.cnt_model_maker_type / t2.cnt_model_maker) * 100, 2) proc
          from ( --Число моделей по типу и производителю
                 select maker, type, count(*) cnt_model_maker_type
                   from product
                  group by maker, type
                  order by maker, type) t1,
                ( --Число моделей по производителю
                 select maker, count(*) cnt_model_maker
                   from product
                  group by maker
                  order by maker) t2
         where t1.maker = t2.maker) t3
 where t4.maker = t3.maker(+)
   and t4.type = t3.type(+)
order by t4.maker, t4.type




select t1.maker,
       t1.type,
--       t1.cnt_model_maker_type,
--       t2.cnt_model_maker,
       round((t1.cnt_model_maker_type / t2.cnt_model_maker) * 100, 2) proc
  from (
        --Число моделей по типу и производителю
        select maker, type, count(*) cnt_model_maker_type
          from product
         group by maker, type
         order by maker, type) t1,
       (
        --Число моделей по производителю
        select maker, count(*) cnt_model_maker
          from product
         group by maker
         order by maker) t2
 where t1.maker = t2.maker

select  pptt.maker, pptt.type, t1.maker, t1.type from 
(select pp.maker, tt.type
          from (select type from product group by type) tt,
               (select maker from product group by maker) pp) pptt,
(select  maker, type from  product group by maker, type)  t1               
where pptt.maker = t1.maker(+) 
      and pptt.type = t1.type(+)
--group by  pptt.maker, pptt.type
order by  pptt.maker, pptt.type


select type, maker from product p1
group by type, maker
order by type, maker



select pp.maker, tt.type from 
(
select type from product
group by type
) tt,
(
select maker from product 
group by maker
) pp
order by pp.maker, tt.type

Задание: 41 (Serge I: 2019-05-31)
Для каждого производителя, у которого присутствуют модели хотя бы в одной из таблиц PC, Laptop или Printer,
определить максимальную цену на его продукцию.
Вывод: имя производителя, если среди цен на продукцию данного производителя присутствует NULL, то выводить для этого производителя NULL,
иначе максимальную цену.

select * from product where model=1260
select * from pc
--970,00
update pc set price=970 where code=12

select * from Product pr, pc p1
where pr.model=p1.model


select t1.maker,
       case
         when t2.isnull = 1 then
          null
         else
          t1.m_price
       end  as m_price
  from (select maker, max(price) m_price
          from (select pr.maker, p1.price
                  from Product pr, pc p1
                 where pr.model = p1.model
                union all
                select pr.maker, lt.price
                  from Product pr, Laptop lt
                 where pr.model = lt.model
                union all
                select pr.maker, pt.price
                  from Product pr, Printer pt
                 where pr.model = pt.model)
         group by maker) t1,
       (select pr.maker, 1 as isnull
          from Product pr, pc p1
         where pr.model = p1.model
           and p1.price is null
        union
        select pr.maker, 1 as isnull
          from Product pr, laptop lt
         where pr.model = lt.model
           and lt.price is null
        union
        select pr.maker, 1 as isnull
          from Product pr, printer pt
         where pr.model = pt.model
           and pt.price is null) t2
 where t1.maker = t2.maker(+)


Задание: 40 (Serge I: 2012-04-20)

Найти производителей, которые выпускают более одной модели, при этом все выпускаемые производителем модели являются продуктами одного типа.
Вывести: maker, type

select maker, type
  from (select type, maker, count(*)
          from product
         group by type, maker
        having count(*) > 1)
 where maker in (select maker
                   from (select maker, type from product group by maker, type)
                  group by maker
                 having count(*) = 1)
                 
Задание: 24 (Serge I: 2003-02-03)
Перечислите номера моделей любых типов, имеющих самую 
высокую цену по всей имеющейся в базе данных продукции.

with 
al as
(
select distinct pc.model, pc.price from pc
where pc.price=(select max(price) from pc)
union
select distinct l.model, l.price from laptop l
where l.price=(select max(price) from laptop)
union
select distinct p.model, p.price from printer p
where p.price=(select max(price) from printer)
) 
select al.model from al where al.price=(select max(al.price) from al)



Задание: 7 (Serge I: 2002-11-02)
Найдите номера моделей и цены всех имеющихся 
в продаже продуктов (любого типа) производителя B (латинская буква).

select pd.model, price 
from product pd, pc c
where pd.model=c.model
and maker='B'
union
select pd.model, price 
from product pd, laptop l
where pd.model=l.model
and maker='B'
union
select pd.model, price 
from product pd, printer pt
where pd.model=pt.model
and maker='B'

Задание: 8 (Serge I: 2003-02-03)
Найдите производителя, выпускающего ПК, но не ПК-блокноты.
select maker from product pd1
where pd1.type='PC'
EXCEPT 
select maker from product pd2
where pd2.type='Laptop'

select maker from product p where p.type='Printer'

Select * from PC

code  model speed ram hd  cd  price
1 1232  500 64  5.0 12x 600.0000
10  1260  500 32  10.0  12x 350.0000
11  1233  900 128 40.0  40x 980.0000
12  1233  800 128 20.0  50x 970.0000
2 1121  750 128 14.0  40x 850.0000
3 1233  500 64  5.0 12x 600.0000
4 1121  600 128 14.0  40x 850.0000
5 1121  600 128 8.0 40x 850.0000
6 1233  750 128 20.0  50x 950.0000
7 1232  500 32  10.0  12x 400.0000
8 1232  450 64  8.0 24x 350.0000
9 1232  450 32  10.0  24x 350.0000

Задание: 23 (Serge I: 2003-02-14)
Найдите производителей, которые производили бы как ПК
со скоростью не менее 750 МГц, так и ПК-блокноты со скоростью не менее 750 МГц.
Вывести: Maker

select distinct maker from product pd, pc 
where pd.model=pc.model and pc.speed>=750
intersect
select distinct maker from product pd, laptop l 
where pd.model=l.model and l.speed>=750

Задание: 22 (Serge I: 2003-02-13)
Для каждого значения скорости ПК, превышающего 600 МГц, определите среднюю цену 
ПК с такой же скоростью. Вывести: speed, средняя цена.

select speed, avg(price) from pc where speed > 600 
group by speed

Задание: 21 (Serge I: 2003-02-13)
Найдите максимальную цену ПК, выпускаемых каждым производителем, 
у которого есть модели в таблице PC. 
Вывести: maker, максимальная цена.

select p.maker, max(pc.price)
from product p, pc
where p.model=pc.model 
and p.type='PC'
group by p.maker

Задание: 20 (Serge I: 2003-02-13)
Найдите производителей, выпускающих по меньшей мере три различных модели ПК. 
Вывести: Maker, число моделей ПК.

select maker, count(*) from product where type='PC'
group by maker
having count(*) >=3


Задание: 17 (Serge I: 2003-02-03)
Найдите модели ПК-блокнотов, скорость которых меньше скорости любого из ПК. 
Вывести: type, model, speed

select 'Laptop' as type, model, speed from laptop where speed<(select min(speed) from pc)

select distinct p.type, l.model, l.speed
  from laptop l, product p
 where l.model=p.model
 and l.speed < (select min(speed) from pc)
 

select p.type, l.model, l.speed
  from laptop l
  inner join product p on l.model=p.model and p.type = 'laptop';
 where l.speed < ALL (select speed from pc)


Задание: 16 (Serge I: 2003-02-03)
Найдите пары моделей PC, имеющих одинаковые скорость и RAM. В результате каждая пара 
указывается только один раз, т.е. (i,j), но не (j,i), Порядок вывода: 
модель с большим номером, модель с меньшим номером, скорость и RAM.


select p1.model, p2.model, p1.speed, p1.ram from pc p1, pc p2 
where p1.speed=p2.speed
and p1.ram=p2.ram
--and p1.model != p2.model
and p1.model > p2.model
--group by p1.model, p2.model, p1.speed, p1.ram 
order by p1.model desc--, p2.model, p1.speed, p1.ram 


Задание: 15 (Serge I: 2003-02-03)
Найдите размеры жестких дисков, совпадающих у двух и более PC. Вывести: HD

select hd from pc 
group by hd
having count(*)>1

Задание: 13 (Serge I: 2002-11-02)
Найдите среднюю скорость ПК, выпущенных производителем A.
select avg(pc.speed)
from pc where exists (select 1 from product pd where pd.model=pc.model and pd.maker='A')


Задание: 11 (Serge I: 2002-11-02)
Найдите среднюю скорость ПК.
select avg(pc.speed)
from pc

Задание: 9 (Serge I: 2002-11-02)
Найдите производителей ПК с процессором не менее 450 Мгц. Вывести: Maker

select pd.maker
from pc, product pd 
where pc.model = pd.model 
and pc.speed >= 450
group by pd.maker
order by pd.maker

Задание: 5 (Serge I: 2002-09-30)
Найдите номер модели, скорость и размер жесткого диска ПК, 
имеющих 12x или 24x CD и цену менее 600 дол.
select model, speed, hd from pc where (cd in ('12x','24x')) and price < 600

Select * from Laptop

code  model speed ram hd  price screen
1 1298  350 32  4.0 700.0000  11
2 1321  500 64  8.0 970.0000  12
3 1750  750 128 12.0  1200.0000 14
4 1298  600 64  10.0  1050.0000 15
5 1752  750 128 10.0  1150.0000 14
6 1298  450 64  10.0  950.0000  12

Задание: 19 (Serge I: 2003-02-13)
Для каждого производителя, имеющего модели в таблице Laptop, 
найдите средний размер экрана выпускаемых им ПК-блокнотов. 
Вывести: maker, средний размер экрана.

select p.maker, avg(l.screen) from product p, laptop l
where p.model=l.model
group by p.maker

Задание: 12 (Serge I: 2002-11-02)
Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол.
select avg(l.speed) 
from laptop l 
where l.price > 1000


Задание: 6 (Serge I: 2002-10-28)
Для каждого производителя, выпускающего ПК-блокноты c объёмом жесткого диска 
не менее 10 Гбайт, найти скорости таких ПК-блокнотов. Вывод: производитель, скорость.

select p.maker, l.speed from product p, laptop l 
where p.model=l.model and l.hd >= 10
group by p.maker, l.speed
order by p.maker, l.speed


Select * from Printer

code  model color type  price
1 1276  n Laser 400.0000
2 1433  y Jet 270.0000
3 1434  y Jet 290.0000
4 1401  n Matrix  150.0000
5 1408  n Matrix  270.0000
6 1288  n Laser 400.0000

Задание: 35 (qwrqwr: 2012-11-23)

В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра).
Вывод: номер модели, тип модели.

select 1 from dual
where (not REGEXP_LIKE('97','[^0-9]')) or (not REGEXP_LIKE('97.','[^A-Z]'))

SELECT model, type
FROM product
where (not REGEXP_LIKE(model,'[^0-9]')) or (not REGEXP_LIKE(upper(model),'[^A-Z]'))

select 1 from dual
where not REGEXP_LIKE(upper('A9'),'[A-Z]')

 select * from Product
 select * from pc
 select * from Laptop
 select * from Printer

SELECT model, type
FROM product
WHERE not REGEXP_LIKE(upper(model),'[A-Z]')) or (not REGEXP_LIKE(model,'[0-9]'))

/* 
select REGEXP_SUBSTR('2356789','[0-9]') from dual

select 1 from dual
where REGEXP_LIKE('A','[0-9]')

SELECT model, type
FROM product
WHERE REGEXP_SUBSTR(model,'[^0-9]')
 */

/* 
SELECT model, type
FROM product
WHERE upper(model) NOT like '%[^A-Z]%'
OR model not like '%[^0-9]%'
*/ 




Задание: 18 (Serge I: 2003-02-03)
Найдите производителей самых дешевых цветных принтеров. Вывести: maker, price

select distinct p.maker, pt.price 
from  printer pt, product p 
where pt.model=p.model
and pt.color='y'
and pt.price = (select min(p1.price) from printer p1 where p1.color='y')


Задание: 10 (Serge I: 2002-09-23)
Найдите модели принтеров, имеющих самую высокую цену. Вывести: model, price

select model, price from Printer
where price=(select max(price) from Printer)


Задание: 4 (Serge I: 2002-09-21)
Найдите все записи таблицы Printer для цветных принтеров.
select * from Printer where color ='y'

Задание: 25 (Serge I: 2003-02-14)
Найдите производителей принтеров, которые производят ПК с наименьшим объемом 
RAM и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker

select distinct p.maker from product p
where p.type='Printer'
and exists (select 1 from pc where pc.

select * from pc pc1 where pc1.ram=(select min(ram) from pc)

select distinct p1.maker
  from product p1
 where p1.type = 'Printer'
intersect
select distinct maker
  from (select p2.maker
          from product p2, pc pc0
         where p2.type = 'PC'
           and p2.model = pc0.model
           and pc0.speed =
               (select max(speed)
                  from (select pc1.speed
                          from pc pc1
                         where pc1.ram = (select min(ram) from pc))))


SELECT DISTINCT maker
  FROM Product
 WHERE type = 'Printer'
   AND maker IN
       (SELECT maker
          FROM Product
         WHERE model IN
               (SELECT model
                  FROM PC
                 WHERE speed =
                       (SELECT MAX(speed)
                          FROM (SELECT speed
                                  FROM PC
                                 WHERE ram = (SELECT MIN(ram) FROM PC))a)))

--ВЕРНОЕ РЕШЕНИЕ                                 
SELECT DISTINCT maker
FROM Product p,
     PC,
     (SELECT max(PC.speed) speed,
             min(minram.val) minram
      FROM PC,
           (SELECT min(ram) val
            FROM PC
           ) minram
      WHERE PC.ram = minram.val
     ) values1
WHERE p.model = PC.model and
      PC.speed = values1.speed and
      PC.ram = values1.minram and
      p.maker in (SELECT maker
                   FROM Product p2
                  WHERE p2.type = 'Printer')                                 


SELECT max(PC.speed) speed, min(minram.val) minram
  FROM PC, (SELECT min(ram) val FROM PC) minram
 WHERE PC.ram = minram.val

Задание: 26 (Serge I: 2003-02-14)
Найдите среднюю цену ПК и ПК-блокнотов, выпущенных производителем A (латинская буква). 
Вывести: одна общая средняя цена.



select avg(price) from
(select price
from product pd, pc 
where pd.model=pc.model
and pd.maker='A'
union all
select price
from product pd, laptop l 
where pd.model=l.model
and pd.maker='A') a

Задание: 27 (Serge I: 2003-02-03)
Найдите средний размер диска ПК каждого из тех производителей, которые выпускают и принтеры. 
Вывести: maker, средний размер HD.

SELECT p1.maker, avg(pc.hd)
  FROM Product p1, pc
 WHERE p1.model = pc.model
   and p1.maker in (SELECT maker FROM Product p2 WHERE p2.type = 'Printer')
group by p1.maker   

Задание: 28 (Serge I: 2012-05-04)
Используя таблицу Product, определить количество производителей, выпускающих по одной модели.

select count(*) from
(select maker, cnt from 
(SELECT p1.maker, count(*) cnt 
  FROM Product p1
group by p1.maker  
) t1  where t1.cnt=1) 

select count(*) from
(SELECT p1.maker, count(*) cnt 
  FROM Product p1
group by p1.maker  
having count(*)=1)


Краткая информация о базе данных "Корабли":

Скрыть
Рассматривается БД кораблей, участвовавших во второй мировой войне. Имеются следующие отношения:
Classes (class, type, country, numGuns, bore, displacement)
Ships (name, class, launched)
Battles (name, date)
Outcomes (ship, battle, result) 
Корабли в «классах» построены по одному и тому же проекту, 
и классу присваивается либо имя первого корабля, построенного по данному проекту, 
либо названию класса дается имя проекта, которое не совпадает ни с одним из кораблей в БД. 
Корабль, давший название классу, называется головным.

Отношение Classes содержит имя класса, тип (bb для боевого (линейного) корабля или 
bc для боевого крейсера), страну, в которой построен корабль, число главных орудий, 
калибр орудий (диаметр ствола орудия в дюймах) и водоизмещение ( вес в тоннах). 
select * from classes;

CLASS TYPE  COUNTRY NUMGUNS BORE  DISPLACEMENT
Bismarck  bb  Germany 8 15  42000
Iowa  bb  USA 9 16  46000
Kongo bc  Japan 8 14  32000
North Carolina  bb  USA 12  16  37000
Renown  bc  Gt.Britain  6 15  32000
Revenge bb  Gt.Britain  8 15  29000
Tennessee bb  USA 12  14  32000
Yamato  bb  Japan 9 18  65000


В отношении Ships записаны название корабля, имя его класса и год спуска на воду. 

select * from ships;

NAME  CLASS LAUNCHED
California  Tennessee 1921
Haruna  Kongo 1916
Hiei  Kongo 1914
Iowa  Iowa  1943
Kirishima Kongo 1915
Kongo Kongo 1913
Missouri  Iowa  1944
Musashi Yamato  1942
New Jersey  Iowa  1943
North Carolina  North Carolina  1941
Ramillies Revenge 1917
Renown  Renown  1916
Repulse Renown  1916
Resolution  Renown  1916
Revenge Revenge 1916
Royal Oak Revenge 1916
Royal Sovereign Revenge 1916
Tennessee Tennessee 1920
Washington  North Carolina  1941
Wisconsin Iowa  1944
Yamato  Yamato  1941
South Dakota  North Carolina  1941


В отношение Battles включены название и дата битвы, в которой участвовали корабли, 

select * from battles;

NAME	R_DATE
Guadalcanal	15.11.1942
North Atlantic	25.05.1941
North Cape	26.12.1943
Surigao Strait	25.10.1944
#Cuba62a	20.10.1962
#Cuba62b	25.10.1962


а в отношении Outcomes – результат участия данного корабля в битве 
(потоплен-sunk, поврежден - damaged или невредим - OK). 
Замечания. 1) В отношение Outcomes могут входить корабли, отсутствующие в отношении Ships. 
2) Потопленный корабль в последующих битвах участия не принимает.


select * from  outcomes;

SHIP  BATTLE  RESULT
Bismarck  North Atlantic  sunk
California  Surigao Strait  OK
Duke of York  North Cape  OK
Fuso  Surigao Strait  sunk
Hood  North Atlantic  sunk
King George V North Atlantic  OK
Kirishima Guadalcanal sunk
Prince of Wales North Atlantic  damaged
Rodney  North Atlantic  OK
Schamhorst  North Cape  sunk
South Dakota  Guadalcanal damaged
Tennessee Surigao Strait  OK
Washington  Guadalcanal OK
West Virginia Surigao Strait  OK
Yamashiro Surigao Strait  sunk
California  Guadalcanal damaged


Задание: 148 (Serge I: 2009-08-11)

Для таблицы Outcomes преобразовать названия кораблей, содержащих более одного пробела, следующим образом.
Заменить все символы между первым и последним пробелами (исключая сами эти пробелы) на символы звездочки (*)
в количестве, равном числу замененных символов.
Вывод: название корабля, преобразованное название корабля

Подcказки к задаче №148

Учтите имя корабля, состоящее из одних пробелов.

select ship, 
       sbstrBegin || ' ' || rpad('*',length(sbstr),'*') || ' ' || sbstrEnd finalstr
       from
(
select ship, 
       REGEXP_INSTR(ship,' ',1,1) pos1, --позиция первого пробела
       REGEXP_INSTR(ship,' ',1,REGEXP_COUNT(ship,' ')) poslast, --позиция последнего пробела
       --REGEXP_COUNT(ship,' '),       
       substr(ship,1,REGEXP_INSTR(ship,' ',1,1)-1) sbstrBegin,--начало строки       
       --Заменяемая подстрока
       substr(ship,REGEXP_INSTR(ship,' ',1,1)+1,REGEXP_INSTR(ship,' ',1,REGEXP_COUNT(ship,' '))-REGEXP_INSTR(ship,' ',1,1)-1) sbstr,
       substr(ship,REGEXP_INSTR(ship,' ',1,REGEXP_COUNT(ship,' '))+1,length(ship)) sbstrEnd --конец строки      
       from Outcomes
where REGEXP_COUNT(ship,' ') >=2 
)

/*
ship	new_name
Duke of York	Duke ** York
King George V	King ****** V
Prince of Wales	Prince ** Wales
*/

select * from Outcomes for update


Задание: 143 (Serge I: 2011-10-08)

Для каждого сражения определить день, являющийся последней пятницей месяца, 
в котором произошло данное сражение.
Вывод: сражение, дата сражения, дата последней пятницы месяца.
Даты представить в формате "yyyy-mm-dd"


select name,
       to_char("date", 'yyyy-mm-dd') d,
       to_char(max(daym), 'yyyy-mm-dd') as LAST_FRIDAY
  from (select name, "date", trunc("date", 'mm') - 1 + trn.rn daym
          from battles,
               (select rownum rn from dual connect by rownum <= 31) trn)
 where trunc("date", 'mm') = trunc(daym, 'mm')
   and trim(to_char(daym, 'DAY', 'nls_date_language = AMERICAN')) =
       'FRIDAY'
 group by name, "date"
 order by name, "date"



/*
NAME  D LAST_FRIDAY
#Cuba62a  1962-10-20  1962-10-26
#Cuba62b  1962-10-25  1962-10-26
Guadalcanal 1942-11-15  1942-11-27
North Atlantic  1941-05-25  1941-05-30
North Cape  1943-12-26  1943-12-31
Surigao Strait  1944-10-25  1944-10-27
*/


Задание: 140 (no_more: 2017-07-07)

Определить, сколько битв произошло в течение каждого десятилетия, 
начиная с даты первого сражения в базе данных и до даты последнего. 
Вывод: десятилетие в формате "1940s", количество битв.

with tmp
as
(
select "date",
       --to_number(to_char("date", 'yyyy')) yr,              
       to_number(substr(to_char("date", 'yyyy'),1,3)||'0') years
from battles
),
tmp2 as 
(
select distinct to_number(substr(yr,1,3)||'0') years from     
(
select (select min(years) from tmp) + rownum yr
from dual 
connect by rownum <= (select max(years) from tmp) - (select min(years) from tmp)        
))
select to_char(years)||'s' years, count("date") battles from
(
select "date", years from tmp
union all
select null as "date", years from tmp2
where not exists (select 1 from tmp where tmp.years=tmp2.years)
) 
group by years
order by years

/*
YEARS	BATTLES
1940s	4
1950s	0
1960s	2
*/

Задание: 136 (Serge I: 2017-01-13)

Для каждого корабля из таблицы Ships, в имени которого есть символы, 
не являющиеся латинской буквой, вывести:
имя корабля, позиционный номер первого небуквенного 
символа в имени и сам символ.


select name, REGEXP_INSTR(upper(name),'[^A-Z]') n, substr(name,REGEXP_INSTR(upper(name),'[^A-Z]'),1) let from
(
select name from ships
where REGEXP_LIKE(upper(name),'[^A-Z]')
and REGEXP_LIKE(lower(name),'[^a-z]')
)

/*
NAME  N LET
New Jersey  4 
North Carolina  6 
Royal Oak 6 
Royal Sovereign 6 
South Dakota  6 
*/

SELECT REGEXP_INSTR ('Oracle Cloud Infrastructure', 'o') FROM dual;


with ABC as (
  select column_value as symbol
  from table(sys.odcivarchar2list('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'))
)
select symbol, 
       nlssort(symbol) nls_code_hex
from ABC
order by symbol


select column_value as symbol
from table(sys.odcivarchar2list('a','b','c','d','e','f','g','h','i','j','k','l','m',
'n','o','p','q','r','s','t','u','v','w','x','y','z'))
union 
select upper(column_value) as symbol
from table(sys.odcivarchar2list('a','b','c','d','e','f','g','h','i','j','k','l','m',
'n','o','p','q','r','s','t','u','v','w','x','y','z'))


with latalf as
(
select 'A' lat from dual union all select 'B' lat from dual union all select 'C' lat from dual union all 
select 'D' lat from dual union all select 'E' lat from dual union all select 'F' lat from dual union all 
select 'G' lat from dual union all select 'H' lat from dual union all select 'I' lat from dual union all 
select 'J' lat from dual union all select 'K' lat from dual union all select 'L' lat from dual union all 
select 'M' lat from dual union all select 'N' lat from dual union all select 'O' lat from dual union all 
select 'P' lat from dual union all select 'Q' lat from dual union all select 'R' lat from dual union all 
select 'S' lat from dual union all select 'T' lat from dual union all select 'U' lat from dual union all 
select 'V' lat from dual union all select 'W' lat from dual union all select 'X' lat from dual union all 
select 'Y' lat from dual union all select 'Z' lat from dual
) select lat lat_u, lower(lat) lat_l from latalf



Задание: 35 (qwrqwr: 2012-11-23)

В таблице Product найти модели, которые состоят только из цифр или только из латинских букв (A-Z, без учета регистра).
Вывод: номер модели, тип модели.

select 1 from dual
where (not REGEXP_LIKE('97','[^0-9]')) or (not REGEXP_LIKE('97.','[^A-Z]'))

SELECT model, type
FROM product
where (not REGEXP_LIKE(model,'[^0-9]')) or (not REGEXP_LIKE(upper(model),'[^A-Z]'))



/*
NAME  N LET
New Jersey  4 
North Carolina  6 
Royal Oak 6 
Royal Sovereign 6 
South Dakota  6 
*/

Задание: 132 (qwrqwr: 2015-10-16)

Для каждой даты битвы (date1) взять дату следующей в хронологическом порядке битвы (date2), 
а если такой даты нет, то текущую дату.
Определить на дату date2 возраст человека, родившегося в дату date1 (число полных лет и полных месяцев).
Замечания:
1) считать, что полное число месяцев исполняется в дату дня рождения, или ранее, 
ри условии, что более поздних дат в искомом месяце нет; 
за полный год принимаются 12 полных месяцев; все битвы произошли в разные 
даты и до сегодняшнего дня.
2) даты представить без времени в формате "yyyy-mm-dd", возраст в формате "Y y., M m.", 
не выводить год или месяц если они равны 0, 
для возраста менее 1 мес. выводить пустую строку. 
Вывод: возраст, date1, date2.

Подcказки к задаче №132

Проверьте случай, когда день рождения приходится на 31 января.


select case when (mns < 1) then null
            when (mns >= 1) and (mns < 12) then to_char(mns)||' m.' 
            when mns >= 12 then to_char(trunc(mns/12)) || ' y., ' || to_char(mod(mns,12)) || ' m.' end age,
            to_char(dt1, 'yyyy-mm-dd') dt1, 
            to_char(dt2, 'yyyy-mm-dd') dt2
from 
(
select trunc(months_between(dt2,dt1)) mns,
       months_between(dt2,dt1), 
       dt2 - dt1, 
       EXTRACT(DAY from (dt2 - dt1)) as days,
       dt1,
       dt2
from
(
select dt dt1,
       --coalesce(nxt_dt,sysdate) dt2
       case when nxt_dt is null then sysdate else nxt_dt end dt2
from
(
select "date" dt, 
       lead("date") over(order by "date") nxt_dt 
from battles       
)))



select case when (mns < 1) then null
            when (mns >= 1) and (mns < 12) then to_char(trunc(mns))||' m.' 
            when mns >= 12 then to_char(trunc(mns/12)) || ' y., ' || to_char(trunc(mod(mns,12))) || ' m.' end age,
            to_char(dt1, 'yyyy-mm-dd') dt1, 
            to_char(dt2, 'yyyy-mm-dd') dt2,
            mns,
            days,
            days/mns
from 
(
select months_between(dt2,dt1) mns,
       months_between(dt2,dt1), 
       dt2 - dt1, 
       EXTRACT(DAY from (dt2 - dt1)) as days,
       EXTRACT(DAY from (dt2 - dt1))/30 as daysDiv30,
       dt1,
       dt2
from
(
select dt dt1,
       case when nxt_dt is null then sysdate else nxt_dt end dt2
from
(
select "date" dt, 
       lead("date") over(order by "date") nxt_dt 
from battles       
)))



select months_between(to_date('01.03.2019','dd.mm.yyyy'),to_date('31.01.2019','dd.mm.yyyy')) from dual


select EXTRACT(DAY from age) days,
       EXTRACT(hour from age) hours,
       age,
       age2,
       trunc(months_between(dt2,dt1)) mns,
       dt1,
       dt2,
       dt1_str,
       dt2_str
from
(
select nvl(nxt_dt,cast(sysdate as timestamp)) - dt as age,
       nvl(cast(nxt_dt as date),sysdate) - cast(dt as date) age2, 
       cast(dt as date) dt1,
       nvl(cast(nxt_dt as date),sysdate) dt2,
       to_char(dt, 'yyyy-mm-dd') dt1_str, 
       to_char(nvl(nxt_dt,sysdate), 'yyyy-mm-dd') dt2_str
from
(
select "date" dt, 
       lead("date") over(order by "date") nxt_dt 
from battles       
)
)

/*
AGE DT1 DT2
1 y., 5 m.  1941-05-25  1942-11-15
1 y., 1 m.  1942-11-15  1943-12-26
9 m.  1943-12-26  1944-10-25
17 y., 11 m.  1944-10-25  1962-10-20
1962-10-20  1962-10-25
57 y., 2 m. 1962-10-25  2019-12-26

*/


Задание: 130 (Velmont: 2015-08-14)

Историки решили составить отчет о битвах в два суперстолбца. 
Каждый суперстолбец состоит из трёх столбцов (номер битвы, название и дата). 
Сначала в порядке возрастания номеров заполняется первый суперстолбец, потом - второй. 
Порядковый номер битве назначается согласно сортировке: дата, название. 
С целью экономии бумаги, историки делят информацию из таблицы Battles поровну, 
занося в первый суперстолбец на одну битву больше при их нечетном количестве.
В таблицу с шестью колонками вывести результат работы историков, пустые места заполнить NULL-значениями.


with src as
 (select count(*) over() maxrn,
         row_number() over(order by "date", name) rn,
         name,
         "date"
    from battles),
partleft as
 (select rn as rn_1,
         name as name_1,
         "date" as date_1,
         row_number() over(order by "date", name) connect_rn
    from src
   where rn <= (case
           when mod(maxrn, 2) = 0 then
            maxrn
           else
            maxrn + 1
         end) / 2),
partright as
 (select rn as rn_2,
         name as name_2,
         "date" as date_2,
         row_number() over(order by "date", name) connect_rn
    from src
   where rn > (case
           when mod(maxrn, 2) = 0 then
            maxrn
           else
            maxrn + 1
         end) / 2)
select rn_1, name_1, date_1, rn_2, name_2, date_2
  from partleft l, partright r
 where l.connect_rn = r.connect_rn(+)


/*
RN_1  NAME_1  DATE_1  RN_2  NAME_2  DATE_2
1 North Atlantic  1941-05-25 00:00:00 4 Surigao Strait  1944-10-25 00:00:00
2 Guadalcanal 1942-11-15 00:00:00 5 #Cuba62a  1962-10-20 00:00:00
3 North Cape  1943-12-26 00:00:00 6 #Cuba62b  1962-10-25 00:00:00
*/



Задание: 121 (Serge I: 2005-05-23)

Найдите названия всех тех кораблей из базы данных, о которых можно определенно сказать, 
что они были спущены на воду до 1941 г. 

Подcказки к задаче №121

1. Может существовать класс без головного корабля, 
поэтому брать имя класса в качестве имени корабля неправильно.
2. Головной корабль следует выводить, даже если год спуска 
на воду всех кораблей данного класса неизвестен, 
НО хотя бы один из них участвовал в сражении до 41 года.
3. Возможна ситуация, когда головной корабль 
с неизвестным годом спуска на воду находится только в таблице Ships.
4. Следует учесть, что столбец [date] имеет тип datetime.


select s.name--, s.launched yr 
from ships s
where s.launched < 1941
union
select o.ship name--, b."date", to_char(b."date",'yyyy') yr, trunc(cast(b."date" as date),'yyyy') 
from outcomes o,  battles b
where o.battle = b.name 
--4. Следует учесть, что столбец [date] имеет тип datetime.
and trunc(cast(b."date" as date),'yyyy')< to_date('01.01.1941','dd.mm.yyyy')
union
select o.ship name from classes c, outcomes o, battles b
where c.class = o.ship and o.battle = b.name
--2. Головной корабль следует выводить, даже если год спуска 
--на воду всех кораблей данного класса неизвестен, 
--НО хотя бы один из них участвовал в сражении до 41 года.
and trunc(cast(b."date" as date),'yyyy')< to_date('01.01.1941','dd.mm.yyyy')






select o.ship from classes c, outcomes o, battles b
where c.class = o.ship and o.battle = b.name
and trunc(cast(b."date" as date),'yyyy')< to_date('01.01.1941','dd.mm.yyyy');

select * from ships s
         , outcomes o
where s.name = o.ship(+)
      and s.launched < 1941
      
/*      
NAME
California
Haruna
Hiei
Kirishima
Kongo
Ramillies
Renown
Repulse
Resolution
Revenge
Royal Oak
Royal Sovereign
Tennessee      
*/      

Задание: 118 (qwrqwr: 2013-12-11)

Выборы Директора музея ПФАН проводятся только в високосный год, в первый вторник 
апреля после первого понедельника апреля.
Для каждой даты из таблицы Battles определить дату ближайших (после этой даты) выборов Директора музея ПФАН.
Вывод: сражение, дата сражения, дата выборов. Даты выводить в формате "yyyy-mm-dd".

with dates as
(
select (select cast(min("date") as date) from Battles)  + rownum as dt
  from dual
--Количество дней между максимальной и минимальной датами сражений + 5 лет                     
connect by rownum <= (select cast(max("date") as date) -
                             cast(min("date") as date) + 5 * 365
                        from Battles)
),
mondays as
(
 select name, bdt, min(dt) firstmonday from 
 (
 select b.name, 
        b."date" bdt,  
        d.dt dt
  from Battles b, dates d
  where cast(b."date" as date) < d.dt
  --Только високосные годы
  and to_char(d.dt,'yyyy') in (select to_char(dt,'yyyy') from dates where to_char(dt,'dd.mm') = '29.02')
  --Только апрель
  and to_char(d.dt,'mm')='04'  
  --Только понедельники
  and trim(to_char(d.dt,'DAY','nls_date_language = AMERICAN'))='MONDAY' 
  --order by b.name, b."date", d.dt
  ) group by name, bdt
),
-- select * from mondays
tuesdays as 
(
 select b.name, 
        b."date",  
        d.dt,
        m.firstmonday
         --to_char(min(d.dt) over(partition by b.name order by d.dt),'yyyy-mm-dd') mindt
  from Battles b, dates d, mondays m
  where 1=1 
  and b.name = m.name 
  and b."date" = m.bdt
  and cast(b."date" as date) < d.dt
  --Только високосные годы
  and to_char(d.dt,'yyyy') in (select to_char(dt,'yyyy') from dates where to_char(dt,'dd.mm') = '29.02')
  --Только апрель
  and to_char(d.dt,'mm')='04'  
  --Только вторники
  and trim(to_char(d.dt,'DAY','nls_date_language = AMERICAN'))='TUESDAY' 
  --После первого понедельника апреля
  and d.dt > m.firstmonday 
  --order by b.name, b."date", d.dt
) --select * from tuesdays order by name, "date", dt
select name, 
         to_char("date",'yyyy-mm-dd') BATTLE_DT,  
         to_char(min(dt),'yyyy-mm-dd') ELECTION_DT
from tuesdays
group by name, "date"
order by name, "date"





with dates as
(
select (select cast(min("date") as date) from Battles)  + rownum as dt
  from dual
--Количество дней между максимальной и минимальной датами сражений + 5 лет                     
connect by rownum <= (select cast(max("date") as date) -
                             cast(min("date") as date) + 5 * 365
                        from Battles)
)
 select distinct name, 
        bdt BATTLE_DT, 
        mindt ELECTION_DT 
 from 
 ( 
 select b.name, 
         to_char(b."date",'yyyy-mm-dd') bdt,  
         to_char(d.dt,'yyyy-mm-dd') dt,
         to_char(min(d.dt) over(partition by b.name order by d.dt),'yyyy-mm-dd') mindt
  from Battles b, dates d
  where cast(b."date" as date) < d.dt
  --Только високосные годы
  and to_char(d.dt,'yyyy') in (select to_char(dt,'yyyy') from dates where to_char(dt,'dd.mm') = '29.02')
  --Только апрель
  and to_char(d.dt,'mm')='04'  
  --Только вторники
  and trim(to_char(d.dt,'DAY','nls_date_language = AMERICAN'))='TUESDAY' 
   --order by b.name, b."date", d.dt
  )
  --group by name, bdt, mindt
  order by name, bdt, mindt
  
  


 --select yr from leap_years 

/*
NAME  BATTLE_DT ELECTION_DT
#Cuba62a  1962-10-20  1964-04-07
#Cuba62b  1962-10-25  1964-04-07
Guadalcanal 1942-11-15  1944-04-04
North Atlantic  1941-05-25  1944-04-04
North Cape  1943-12-26  1944-04-04
Surigao Strait  1944-10-25  1948-04-06
*/


-- MSSQL
Select name,
       convert(char(10), date, 120) as battle_dt,
       convert(char(10), MIN(Dateadd(dd, 1, dt)), 120) as election_dt
  From (Select name,
               date,
               Dateadd(yy,
                       p,
                       Dateadd(dd,
                               n,
                               Dateadd(mm,
                                       3,
                                       dateadd(yy, datediff(yy, 0, date), 0)))) as dt
          From Battles,
               (values(0), (1), (2), (3), (4), (5), (6), (7), (8)) T(p),
               (values(0), (1), (2), (3), (4), (5), (6)) W(n)) X
 Where date <= dt
   and (Year(dt) %4 = 0 and Year(dt) %100 > 0 or Year(dt) %400 = 0)
   and DATEPART(dw, dt) = DATEPART(dw, '20140106')
 GROUP BY name, date


select name, "date" from Battles
order by name

--Количество дней между максимальной и минимальной датами сражений + 5 лет
select cast(max("date") as date) - cast(min("date") as date) + 5*365 from Battles 


select dt from 
(
select (select cast(min("date") as date) from Battles)  + rownum as dt
  from dual
connect by rownum <= (select cast(max("date") as date) -
                             cast(min("date") as date) + 5 * 365
                        from Battles)
) where to_char(dt,'dd.mm') = '29.02' 




Задание: 117 (Serge I: 2013-11-29)

По таблице Classes для каждой страны найти максимальное значение среди трех выражений:
numguns*5000, bore*3000, displacement.
Вывод в три столбца:
- страна;
- максимальное значение;
- слово `numguns` - если максимум достигается для numguns*5000, слово `bore` - если максимум достигается для bore*3000, 
слово `displacement` - если максимум достигается для displacement.
Замечание. Если максимум достигается для нескольких выражений, выводить каждое из них отдельной строкой.

with tmp1 as
(
select country, max(numguns*5000) maxnumguns5000, max(bore*3000) maxbore3000, max(displacement) maxdisp from classes
group by country
), 
tmp2 as
(
  select country, maxnumguns5000 max_val, 'numguns' name from tmp1 
  union
  select country, maxbore3000 max_val, 'bore' name from tmp1 
  union
  select country, maxdisp max_val, 'displacement' name from tmp1 
)  select country, max_val, name from tmp2 t1
   where max_val in (select max(t2.max_val) from tmp2 t2 where t2.country=t1.country) 

   


with tmp1 as
(
select country, numguns*5000 numguns5000, bore*3000 bore3000, displacement from classes
),
tmp2 as
(
select country, max(numguns5000) maxnumguns5000, max(bore3000) maxbore3000, max(displacement) maxdisplacement from tmp1
group by country
) select country



/*
COUNTRY	MAX_VAL	NAME
Germany	45000	bore
Gt.Britain	45000	bore
Japan	65000	displacement
USA	60000	numguns
*/

Задание: 104 (Serge I: 2013-07-19)

Для каждого класса крейсеров, число орудий которого известно, 
пронумеровать (последовательно от единицы) все орудия.
Вывод: имя класса, номер орудия в формате 'bc-N'.


select c.class, 'bc-' || to_char(g.num) gnum
  from classes c,
       (select rownum num
          from dual
        connect by rownum <=
                   (select max(c1.numguns) from classes c1 where c1.type = 'bc')) g
 where c.type = 'bc'
   and c.numguns >= g.num
 order by c.class, g.num


with guns as
(
select rownum num
from dual
connect by rownum<=(select max(c.numguns) from classes c where c.type='bc')
)
select c.class, 'bc-'||to_char(g.num) gnum from classes c, guns g
where c.type='bc' and c.numguns >= g.num
order by c.class, g.num



/*
CLASS NUM
Kongo bc-1
Kongo bc-2
Kongo bc-3
Kongo bc-4
Kongo bc-5
Kongo bc-6
Kongo bc-7
Kongo bc-8
Renown  bc-1
Renown  bc-2
Renown  bc-3
Renown  bc-4
Renown  bc-5
Renown  bc-6
*/

Задание: 83 (dorin_larsen: 2006-03-14)

Определить названия всех кораблей из таблицы Ships, которые удовлетворяют, по крайней мере, 
комбинации любых четырёх критериев из следующего списка:
numGuns = 8
bore = 15
displacement = 32000
type = bb
launched = 1915
class=Kongo
country=USA

select s.name
  from ships s, classes c
 where s.class = c.class
   and (case
         when c.numGuns = 8 then
          1
         else
          0
       end + case
         when c.bore = 15 then
          1
         else
          0
       end + case
         when displacement = 32000 then
          1
         else
          0
       end + case
         when c.type = 'bb' then
          1
         else
          0
       end + case
         when s.launched = 1915 then
          1
         else
          0
       end + case
         when c.class = 'Kongo' then
          1
         else
          0
       end + case
         when c.country = 'USA' then
          1
         else
          0
       end) >= 4



Задание: 78 (Serge I: 2005-01-19)

Для каждого сражения определить первый и последний день
месяца,
в котором оно состоялось.
Вывод: сражение, первый день месяца, последний
день месяца.

Замечание: даты представить без времени в формате "yyyy-mm-dd".

select b.name battle,
       --b."date", 
       to_char(trunc(b."date",'mm'),'yyyy-mm-dd') FIRSTD, 
       to_char(add_months(trunc(b."date",'mm')-1, 1),'yyyy-mm-dd') LASTD
from battles b
order by b.name;

/*
BATTLE  FIRSTD  LASTD
#Cuba62a  1962-10-01  1962-10-31
#Cuba62b  1962-10-01  1962-10-31
Guadalcanal 1942-11-01  1942-11-30
North Atlantic  1941-05-01  1941-05-31
North Cape  1943-12-01  1943-12-31
Surigao Strait  1944-10-01  1944-10-31
*/

Задание: 75 (Serge I: 2009-04-17)

Для каждого корабля из таблицы Ships указать название первого по времени сражения из таблицы Battles,
в котором корабль мог бы участвовать после спуска на воду. Если год спуска на воду неизвестен, взять последнее по времени сражение.
Если нет сражения, произошедшего после спуска на воду корабля, вывести NULL вместо названия сражения.
Считать, что корабль может участвовать во всех сражениях, которые произошли в год спуска на воду корабля.
Вывод: имя корабля, год спуска на воду, название сражения

Замечание: считать, что не существует двух битв, произошедших в один и тот же день.


WITH ShBt AS
 (
--указать название первого по времени сражения из таблицы Battles,
--в котором корабль мог бы участвовать после спуска на воду
SELECT s.name as shipname,
       s.launched,
       min(to_number(to_char(b."date", 'yyyy'))) Year_Battle
    FROM Ships s, Battles b
    where s.launched <= to_number(to_char(b."date", 'yyyy'))
group by s.name, s.launched    
union
--Если нет сражения, произошедшего после спуска на воду корабля, вывести NULL вместо названия сражения.
SELECT s.name as shipname,
       s.launched,
       null Year_Battle
    FROM Ships s, Battles b
    where s.launched > (select max(to_number(to_char("date", 'yyyy'))) from Battles)
group by s.name, s.launched    
union
--Если год спуска на воду неизвестен, взять последнее по времени сражение
SELECT s.name as shipname,
       s.launched,
       max(to_number(to_char(b."date", 'yyyy'))) Year_Battle
    FROM Ships s, Battles b
    where s.launched is null
group by s.name, s.launched
)
SELECT ShBt.shipname,
       ShBt.launched,
       min(case ShBt.Year_Battle
             when null then
              NULL
             else
              b.name
           end) batname
  FROM ShBt
  left join Battles b
    on to_number(to_char(b."date", 'yyyy')) = ShBt.Year_Battle
    or ShBt.Year_Battle is null
 GROUP BY ShBt.shipname, ShBt.launched



WITH ShBt AS
 (SELECT s.name,
         s.launched,
         nvl2(s.launched,
              min(to_number(to_char(b."date", 'yyyy'))),
              max(to_number(to_char(b."date", 'yyyy')))) year1
    FROM Ships s
    left join Battles b
      on s.launched <= to_number(to_char(b."date", 'yyyy'))
      or s.launched is null
   GROUP BY s.name, s.launched)
SELECT ShBt.name shipname,
       ShBt.launched,
       min(case ShBt.year1
             when NULL then
              NULL
             else
              b.name
           end) batname
  FROM ShBt
  left join Battles b
    on to_number(to_char(b."date", 'yyyy')) = ShBt.year1
 GROUP BY ShBt.name, ShBt.launched


WITH dsB AS
(SELECT s.name, s.launched, iif(s.launched is null,max(b.date),min(b.date)) year
 FROM Ships s left join Battles b
 on s.launched <= YEAR(b.date) or s.launched is null
 GROUP BY s.name, s.launched
)
SELECT dsB.name, dsB.launched, min(iif(dsB.year=2020,NULL,b.name))
FROM dsB left join Battles b on b.date = dsB.year
GROUP BY dsB.name, dsB.launched




select shipname, launched, batname
  from (
--Для каждого корабля из таблицы Ships указать название первого по времени сражения из таблицы Battles,
--в котором корабль мог бы участвовать после спуска на воду  
select s.name as shipname,
               launched,
               b.name as batname,
               row_number() over(partition by s.name order by "date") as num
          from ships s, battles b
         where to_char("date", 'yyyy') >= launched
           and launched is not null)
 where num = 1
union (
--Если год спуска на воду неизвестен, взять последнее по времени сражение
select name as shipname,
              launched,
              (select name
                 from battles
                where "date" = (select max("date") from battles)) as batname
         from ships
        where launched is null)
union (
--Если нет сражения, произошедшего после спуска на воду корабля, вывести NULL вместо названия сражения        
select name as shipname, launched, null as batname
from ships ss where not exists (select 1 from battles bb where ss.launched <= to_number(to_char(bb."date",'yyyy')))
)

select * from ships s, outcomes o--, battles b
where s.name=o.ship(+)
--      and o.battle=b.name(+)

select name, to_number(to_char(b."date",'yyyy')) as b_year from battles b


select * from ships s, battles b
where s.launched = to_number(to_char(b."date",'yyyy'))


Задание: 74 (dorin_larsen: 2007-03-23)

Вывести классы всех кораблей России (Russia). Если в базе данных нет классов кораблей России, вывести классы для всех имеющихся в БД стран.
Вывод: страна, класс

select c.country, c.class
  from classes c
 where upper(c.country) = 'RUSSIA'
   and exists (select 1
          from classes c1
          where upper(c1.country) = 'RUSSIA')
union 
select c.country, c.class
  from classes c
 where not exists (select 1
          from classes c1
          where upper(c1.country) = 'RUSSIA')


select case country
         WHEN 'Russia' then 'Russia' as country
         ELSE country  
       c.country, c.class from classes c
where c.country='Russia' 
group by c.country, c.class

select c.country, c.class from classes c
group by c.country, c.class



Задание: 73 (Serge I: 2009-04-17)

Для каждой страны определить сражения, в которых не участвовали корабли данной страны.
Вывод: страна, сражение

--все возможные комбинации страна - сражение
select distinct c.country, b.name
from battles b, classes c
minus
--все сражения по странам
select * from 
(
--название корабля совпадает с классом корабля
select c.country, o.battle--, o.ship
from outcomes o, classes c
where o.ship = c.class(+)
and c.country is not null
union
--название корабля не совпадает с классом корабля
select c.country, o.battle--, o.ship
from outcomes o, ships s, classes c
where o.ship = s.name(+)
and s.class=c.class(+)
and c.country is not null
) group by country, battle



--Все возможные комбинации страна - сражение
SELECT DISTINCT c.country, b.name
FROM battles b, classes c
MINUS
--Все сражения по странам
SELECT c.country, o.battle
FROM outcomes o
LEFT JOIN ships s ON s.name = o.ship
LEFT JOIN classes c ON o.ship = c.class OR s.class = c.class
WHERE c.country IS NOT NULL
GROUP BY c.country, o.battle


Задание: 70 (Serge I: 2003-02-14)
Укажите сражения, в которых участвовало по меньшей мере три корабля одной и той же страны.

select distinct battle from 
(
select o.battle, c.country, s.name as ship from outcomes o, ships s, classes c
where o.ship=s.name(+) 
  and s.class=c.class(+)
  and c.country is not null
union 
select o.battle, c.country, o.ship from outcomes o, classes c
where o.ship=c.class(+)
  and c.country is not null
)
group by battle, country
having count(ship) >= 3  
  
  

Задание: 57 (Serge I: 2003-02-14)

Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, 
вывести имя класса и число потопленных кораблей.

select * from 
(
select c1.class,
       (select count(*)
          from (
                --Корабли из outcomes, которые есть в ships
                select c.class, s.name, o.result
                  from outcomes o, ships s, classes c
                 where o.ship = s.name
                   and s.class = c.class
                union
                --Корабли из outcomes, название которых совпадает с классом
                select c.class, o.ship, o.result
                  from outcomes o, classes c
                 where o.ship = c.class) o1
         where o1.result = 'sunk'
           and o1.class = c1.class) as cnt_sunk
  from classes c1
 where c1.class in (select class --, count(*) 
                      from (
                            --Все корабли
                            --Корабли из ships
                            select s1.name, c.class
                              from ships s1, classes c
                             where s1.class = c.class
                            union
                            --Корабли из outcomes
                            select o.ship as name, c.class
                              from outcomes o, classes c
                             where o.ship = c.class)
                     group by class
                    having count(*) >= 3)
) where cnt_sunk > 0                    

Задание: 56 (Serge I: 2003-02-16)

Для каждого класса определите число кораблей этого класса, потопленных в сражениях. 
Вывести: класс и число потопленных кораблей.

select c1.class,
       (select count(*)
          from (
                --Корабли из outcomes, которые есть в ships
                select c.class, s.name, o.result
                  from outcomes o, ships s, classes c
                 where o.ship = s.name
                   and s.class = c.class
                union
                --Корабли из outcomes, название которых совпадает с классом
                select c.class, o.ship, o.result
                  from outcomes o, classes c
                 where o.ship = c.class) o1
         where o1.result = 'sunk'
           and o1.class = c1.class) as cnt_sunk
from classes c1


select c1.class,
       (select count(*) from outcomes o1 where o1.result='sunk' and o1.ship=c1.class) as cnt_sunk
  from classes c1


--Корабли из outcomes, которые есть в ships
select c.class, s.name, o.result  from outcomes o, ships s, classes c
where o.ship=s.name
and s.class=c.class
union 
--Корабли из outcomes, название которых совпадает с классом
select c.class, o.ship, o.result from outcomes o, classes c
where o.ship=c.class



select *
  from outcomes o 
  where 1=1
  and o.result='sunk'
 

select *
  from outcomes o, classes c
 where o.ship = c.class




Задание: 55 (Serge I: 2003-02-16)

Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. 
Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. 
Вывести: класс, год.


SELECT c.class, t.min_launched
  FROM classes c,
       (SELECT class, MIN(launched) AS min_launched
          FROM ships
         GROUP BY class) t
 where c.class = t.class(+)

--не верно, но запрос прикольный
select class, min_launched 
from 
(
select name,
       class,
       launched,
       min(launched) over(PARTITION BY class order by launched) min_launched
                 from (
                        --Корабли из ships
                        select s1.name, c.class, s1.launched
                          from ships s1, classes c
                         where s1.class = c.class
                        union
                        --Корабли из outcomes
                        select o.ship as name, c.class, null
                          from outcomes o, classes c
                         where o.ship = c.class) ts
) 
where nvl(launched,4000) = nvl(min_launched,4000)
group by class, min_launched 



select class, min_launched 
from 
(
select s.name,
       c.class,
       s.launched,
       min(s.launched) over(PARTITION BY c.class order by s.launched) min_launched
  from ships s, classes c
 where s.class = c.class
) 
where launched = min_launched
group by class, min_launched 

Задание: 54 (Serge I: 2003-02-14)

С точностью до 2-х десятичных знаков определите среднее число орудий всех линейных кораблей (учесть корабли из таблицы Outcomes).

select round(avg(numguns),2) avg_numguns
  from (
        --Корабли из ships
        select s1.name, c.class, c.numguns
          from ships s1, classes c
         where s1.class = c.class
           and c.type = 'bb'
        union
        --Корабли из outcomes
        select o.ship as name, c.class, c.numguns
          from outcomes o, classes c
         where o.ship = c.class
           and c.type = 'bb') ts

  



Задание: 53 (Serge I: 2002-11-05)

Определите среднее число орудий для классов линейных кораблей.
Получить результат с точностью до 2-х десятичных знаков.

select round(avg(c.numguns),2) avg_numguns
  from  classes c
 where  c.type='bb' 
 
select *
  from ships s1, classes c
 where s1.class = c.class
 and c.type='bb'  

Задание: 52 (qwrqwr: 2010-04-23)

Определить названия всех кораблей из таблицы Ships, которые могут быть линейным японским кораблем,
имеющим число главных орудий не менее девяти, калибр орудий менее 19 дюймов и водоизмещение не более 65 тыс.тонн

select name
  from ships s1, classes c
 where s1.class = c.class
 and c.type='bb'
 and UPPER(c.country) = 'JAPAN'
 and (numguns>=9 or numguns is NULL)
 AND (c.bore < 19 OR c.bore IS NULL)
 AND (displacement <= 65000 OR c.displacement IS NULL)


Задание: 51 (Serge I: 2003-02-17)
Найдите названия кораблей, имеющих наибольшее число орудий среди всех имеющихся кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).


select name
  from (select *
          from (select name,
                       displacement,
                       numguns,
                       max(numguns) over(PARTITION BY displacement order by numguns desc) max_numguns
                  from (
                        --Корабли из ships
                        select s1.name, c.displacement, c.numguns
                          from ships s1, classes c
                         where s1.class = c.class
                        union
                        --Корабли из outcomes
                        select o.ship as name, c.displacement, c.numguns
                          from outcomes o, classes c
                         where o.ship = c.class) ts)
         where numguns = max_numguns)


select name from 
(select * from 
(
select s1.name, c.displacement, c.numguns, max(c.numguns) over (PARTITION BY c.displacement order by c.numguns desc ) max_numguns 
from ships s1, classes c
where s1.class=c.class
) where numguns=max_numguns
)

SELECT name
  FROM (SELECT O.ship AS name, numGuns, displacement
          FROM Outcomes O
         INNER JOIN Classes C
            ON O.ship = C.class
           AND O.ship NOT IN (SELECT name FROM Ships)
        UNION
        SELECT S.name AS name, numGuns, displacement
          FROM Ships S
         INNER JOIN Classes C
            ON S.class = C.class) OS
 INNER JOIN (SELECT MAX(numGuns) AS MaxNumGuns, displacement
               FROM Outcomes O
              INNER JOIN Classes C
                 ON O.ship = C.class
                AND O.ship NOT IN (SELECT name FROM Ships)
              GROUP BY displacement
             UNION
             SELECT MAX(numGuns) AS MaxNumGuns, displacement
               FROM Ships S
              INNER JOIN Classes C
                 ON S.class = C.class
              GROUP BY displacement) GD
    ON OS.numGuns = GD.MaxNumGuns
   AND OS.displacement = GD.displacement;


select name from 
(
--Максимумы орудий по водоизмещениям
select c.displacement, max(c.numguns) numguns from classes c 
group by c.displacement
--order by c.displacement
) tmax,
(
--Корабли из ships
select s1.name, c.displacement, c.numguns from ships s1, classes c
where s1.class=c.class
union
--Корабли из outcomes
select o.ship as name, c.displacement, c.numguns from outcomes o, classes c
where o.ship=c.class
) ts
where tmax.displacement=ts.displacement
and tmax.numguns=ts.numguns 
group by name
order by name


Задание: 50 (Serge I: 2002-11-05)
Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.

select o.battle from ships s, outcomes o
where s.class='Kongo'
and s.name=o.ship


Задание: 49 (Serge I: 2003-02-17)
Найдите названия кораблей с орудиями калибра 16 дюймов (учесть корабли из таблицы Outcomes).

--Корабли из ships
select s.name from ships s, classes c
where s.class=c.class
and c.bore=16
union
--Корабли из outcomes, которые есть в ships
select o.ship from outcomes o, ships s, classes c
where o.ship=s.name(+)      
and s.class=c.class(+)
and c.bore=16
union 
--Корабли из outcomes, название которых совпадает с классом
select o.ship from outcomes o, classes c
where o.ship=c.class(+)      
and c.bore=16


Задание: 48 (Serge I: 2003-02-16)
Найдите классы кораблей, в которых хотя бы один корабль был потоплен в сражении.

select class from 
(
--Все потопленные корабли
--Потопленные корабли присутствующие в ships
select c.class, o.ship from outcomes o, ships s, classes c
where o.ship=s.name(+)      
and s.class=c.class(+)
and o.result='sunk'
union all
--Потопленные корабли название которых совпадает с классом
select c.class, o.ship from outcomes o, classes c
where o.ship=c.class(+)      
and o.result='sunk'
) 
where class is not null
group by class



Задание: 47 (Serge I: 2019-06-07)
Определить страны, которые потеряли в сражениях все свои корабли.

select t1.country from 
(
select country, count(*) cnt_all from 
(
--Все корабли по странам
--Страны и корабли в ships
select c.country, c.class, s.name from classes c, ships s 
where c.class=s.class
union
--Страны и корабли в outcomes
select c.country, c.class, o.ship as name from classes c, outcomes o
where c.class=o.ship
and not exists (select 1 from ships s1 where s1.name=o.ship) 
) group by country
) t1,
(
select country, count(*) cnt_sunk from 
(
--Все потопленные корабли
--Потопленные корабли присутствующие в ships
select c.country, c.class, o.ship from outcomes o, ships s, classes c
where o.ship=s.name(+)      
and s.class=c.class(+)
and o.result='sunk'
and c.country is not null
union
--Потопленные корабли название которых совпадает с классом
select c.country, c.class, o.ship from outcomes o, classes c
where o.ship=c.class(+)      
and o.result='sunk'
and c.country is not null
) group by country
) t2
where t1.country=t2.country
and t1.cnt_all-t2.cnt_sunk=0



Задание: 46 (Serge I: 2003-02-14)
Для каждого корабля, участвовавшего в сражении при Гвадалканале (Guadalcanal), вывести название, водоизмещение и число орудий.

select o.ship, c.displacement, c.numguns from  outcomes o, ships s, classes c
where o.ship=s.name(+) and s.class=c.class
and o.battle='Guadalcanal';


SELECT o.ship, displacement, numGuns FROM
(SELECT name AS ship, displacement, numGuns
FROM Ships s JOIN Classes c ON c.class=s.class
UNION
SELECT class AS ship, displacement, numGuns
FROM Classes c) a
RIGHT JOIN Outcomes o
ON o.ship=a.ship
WHERE battle = 'Guadalcanal'


SELECT o.ship, displacement, numGuns
  FROM Outcomes o,
       (SELECT name AS ship, displacement, numGuns
          FROM Ships s, Classes c
         WHERE c.class = s.class
        UNION
        SELECT class AS ship, displacement, numGuns
          FROM Classes c) a
 WHERE a.ship = o.ship(+)
   and battle = 'Guadalcanal'


Задание: 45 (Serge I: 2002-12-04)

Найдите названия всех кораблей в базе данных, состоящие из трех и более слов (например, King George V).
Считать, что слова в названиях разделяются единичными пробелами, и нет концевых пробелов.


select name from
(
select name from ships 
union
select ship from outcomes
)
where instr(substr(name, instr(name,' ')+1),' ')>0

select n.name
  from (select name from ships
       union
       select ship from outcomes
       ) n
where instr(n.name, ' ', 1, 2) <>  0 

select instr('King',' '), instr('King George V',' '), instr('King George V',' ', 1, 2),  instr(substr('King George V', instr('King George V',' ')+1),' ')  from dual

Задание: 44 (Serge I: 2002-12-04)
Найдите названия всех кораблей в базе данных, начинающихся с буквы R.

select name from ships
where substr(name,1,1)='R'
union
select ship from outcomes
where substr(ship,1,1)='R'



Задание: 43 (qwrqwr: 2011-10-28)
Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.

select b.name from battles b 
where not exists (select 1 from ships s where s.launched = to_number(to_char(b."date",'yyyy')))

select b.name from battles b 
where to_number(to_char(b."date",'yyyy')) not in (select s.launched from ships s)


Задание: 42 (Serge I: 2002-11-05)
Найдите названия кораблей, потопленных в сражениях, и название сражения, в котором они были потоплены.

select o.ship, o.battle from outcomes o
where o.result='sunk'

select * from outcomes o, battles b  
where o.result='sunk'
and o.battle=b.name(+)


Задание: 39 (Serge I: 2003-02-14)
Найдите корабли, `сохранившиеся для будущих сражений`; т.е. выведенные из строя в одной битве (damaged), они участвовали в другой, произошедшей позже.

select ship from outcomes o
where exists (select 1 from outcomes oo where oo.ship=o.ship and oo.result='damaged') 
group by ship
having count(*)>1

with sb
as
(
select o.*, b.* from outcomes o, battles b
where o.battle=b.name(+)
)
select distinct ship from sb sb1
where exists (select 1 from sb sb2 where sb1.ship=sb2.ship and sb2.result='damaged') 
and exists (select 1 from sb sb3 where sb1.ship=sb3.ship and sb1."date">sb3."date")


WITH sb AS
(SELECT o.ship, b.name, b."date", o.result
FROM outcomes o
LEFT JOIN battles b ON o.battle = b.name )
SELECT DISTINCT t1.ship FROM sb t1
WHERE t1.ship IN
(SELECT t2.ship FROM sb t2
WHERE t2."date" < t1."date" AND t2.result = 'damaged')


Задание: 38 (Serge I: 2003-02-19)
Найдите страны, имевшие когда-либо классы обычных боевых кораблей ('bb') и имевшие когда-либо классы крейсеров ('bc').

select c.country from classes c
where c.type ='bb'
group by country
intersect
select c.country from classes c
where c.type ='bc'
group by country

select country from classes c, ships s
where c.class = s.class
and c.type in ('bb', 'bc')
group by country
union
select country from classes c, outcomes o
where c.class = o.ship
and c.type in ('bb', 'bc')
group by country

Задание: 37 (Serge I: 2003-02-17)
Найдите классы, в которые входит только один корабль из базы данных (учесть также корабли в Outcomes).

SELECT c.class
FROM classes c
 LEFT JOIN (
 SELECT class, name
 FROM ships
 UNION
 SELECT ship, ship
 FROM outcomes
) s ON s.class = c.class
GROUP BY c.class
HAVING COUNT(s.name) = 1


Задание: 36 (Serge I: 2003-02-17)
Перечислите названия головных кораблей, имеющихся в базе данных (учесть корабли в Outcomes).

select name from
(
select c.class, s.name from classes c, ships s
where c.class=s.name
union 
select c.class, o.ship as name from classes c, outcomes o
where c.class=o.ship
)

Задание: 34 (Serge I: 2002-11-04)

По Вашингтонскому международному договору от начала 1922 г. запрещалось строить линейные корабли водоизмещением более 35 тыс.тонн. 
Укажите корабли, нарушившие этот договор (учитывать только корабли c известным годом спуска на воду). Вывести названия кораблей.

--select c.country, c.class, s.name, c.DISPLACEMENT, s.LAUNCHED 
select s.name
from classes c, ships s
where c.class=s.class
and c.DISPLACEMENT > 35000
and s.LAUNCHED >=1922
and c.type='bb'


Задание: 33 (Serge I: 2002-11-02)
Укажите корабли, потопленные в сражениях в Северной Атлантике (North Atlantic). Вывод: ship.

select ship from  outcomes o
where o.battle='North Atlantic' and o.result='sunk'
Задание: 32 (Serge I: 2003-02-17)
Одной из характеристик корабля является половина куба калибра его главных орудий (mw). 
С точностью до 2 десятичных знаков определите среднее значение mw для кораблей каждой страны, у которой есть корабли в базе данных.

/*
select country, round(avg(power(bore,3)/2),2) WEIGHT from classes c, ships s
where s.class=c.class
group by country
order by country

select country, round(avg(power(bore,3)/2),2) WEIGHT from classes c, outcomes o
where c.class=o.ship and o.result='sunk'
group by country
order by country
*/



select country, round(avg(power(bore,3)/2),2) 	WEIGHT from
(
select c.country, c.class, c.bore, s.name from classes c, ships s
where c.class=s.class(+)
union all
select c.country, c.class, c.bore, o.ship as name from classes c, outcomes o
where c.class=o.ship(+) and o.ship not in (select name from ships)
) a
where a.name IS NOT NULL
group by country
--order by country

Select country, cast(avg((power(bore,3)/2)) as numeric(6,2)) as weight
from (select country, classes.class, bore, name from classes left join ships on classes.class=ships.class
union all
select distinct country, class, bore, ship from classes t1 left join outcomes t2 on t1.class=t2.ship
where ship=class and ship not in (select name from ships) ) a
where name IS NOT NULL group by country


Задание: 31 (Serge I: 2002-10-22)
Для классов кораблей, калибр орудий которых не менее 16 дюймов, укажите класс и страну.

select class, country from classes
where bore >= 16

Задание: 14 (Serge I: 2002-11-05)
Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий.
select s.class, s.name, c.country 
from ships s, classes c 
where s.class=c.class
and c.numguns >= 10


Краткая информация о базе данных "Фирма вторсырья"

Фирма имеет несколько пунктов приема вторсырья. Каждый пункт получает деньги для их выдачи сдатчикам вторсырья. 

Сведения о получении денег на пунктах приема записываются в таблицу:
Income_o(point, date, inc)
Первичным ключом является (point, date). При этом в столбец date записывается только дата (без времени), 
т.е. прием денег (inc) на каждом пункте производится не чаще одного раза в день. 

select * from Income_o
POINT, date, INC
1 22.03.01 00:00:00,000000  15000,00
1 23.03.01 00:00:00,000000  15000,00
1 24.03.01 00:00:00,000000  3400,00
1 13.04.01 00:00:00,000000  5000,00
1 11.05.01 00:00:00,000000  4500,00
2 22.03.01 00:00:00,000000  10000,00
2 24.03.01 00:00:00,000000  1500,00
3 13.09.01 00:00:00,000000  11500,00
3 02.10.01 00:00:00,000000  18000,00

Сведения о выдаче денег сдатчикам вторсырья записываются в таблицу:
Outcome_o(point, date, out)
В этой таблице также первичный ключ (point, date) гарантирует отчетность каждого пункта о выданных деньгах (out) не чаще одного раза в день.

select * from Outcome_o;
POINT date  out
1 14.03.01 00:00:00,000000  15348,00
1 24.03.01 00:00:00,000000  3663,00
1 26.03.01 00:00:00,000000  1221,00
1 28.03.01 00:00:00,000000  2075,00
1 29.03.01 00:00:00,000000  2004,00
1 11.04.01 00:00:00,000000  3195,04
1 13.04.01 00:00:00,000000  4490,00
1 27.04.01 00:00:00,000000  3110,00
1 11.05.01 00:00:00,000000  2530,00
2 22.03.01 00:00:00,000000  1440,00
2 29.03.01 00:00:00,000000  7848,00
2 02.04.01 00:00:00,000000  2040,00
3 13.09.01 00:00:00,000000  1500,00
3 14.09.01 00:00:00,000000  2300,00
3 16.09.02 00:00:00,000000  2150,00


В случае, когда приход и расход денег может фиксироваться несколько раз в день, 
используется другая схема с таблицами, имеющими первичный ключ code:
Income(code, point, date, inc)

select * from Income

CODE  POINT date  INC
1 1 22.03.01 00:00:00,000000  15000,00
2 1 23.03.01 00:00:00,000000  15000,00
3 1 24.03.01 00:00:00,000000  3600,00
4 2 22.03.01 00:00:00,000000  10000,00
5 2 24.03.01 00:00:00,000000  1500,00
6 1 13.04.01 00:00:00,000000  5000,00
7 1 11.05.01 00:00:00,000000  4500,00
8 1 22.03.01 00:00:00,000000  15000,00
9 2 24.03.01 00:00:00,000000  1500,00
10  1 13.04.01 00:00:00,000000  5000,00
11  1 24.03.01 00:00:00,000000  3400,00
12  3 13.09.01 00:00:00,000000  1350,00
13  3 13.09.01 00:00:00,000000  1750,00

Outcome(code, point, date, out)
Здесь также значения столбца date не содержат времени. 


Задание: 145 (Serge I: 2019-01-04)

Для каждой пары последовательных дат, dt1 и dt2, поступления средств 
(таблица Income_o) найти сумму выдачи денег (таблица Outcome_o) 
в полуоткрытом интервале (dt1, dt2].
Вывод: сумма, левая граница интервала, правая граница интервала.


select "date" prevdate, 
       inc,
       lead("date") over (order by /*point,*/ "date") as nxtdate 
       from Income_o
       
/*
QTY DT1 DT2
0 2001-03-22 00:00:00 2001-03-23 00:00:00
1500  2001-05-11 00:00:00 2001-09-13 00:00:00
22873.04  2001-03-24 00:00:00 2001-04-13 00:00:00
2300  2001-09-13 00:00:00 2001-10-02 00:00:00
3663  2001-03-23 00:00:00 2001-03-24 00:00:00
5640  2001-04-13 00:00:00 2001-05-11 00:00:00
*/       

select * from Outcome_o oo,
(
select point, 
       "date" prevdate, 
       inc,
       nvl(lead("date") over (order by /*point,*/ "date"),to_date('01.01.4000','dd.mm.yyyy')) as nxtdate 
       from Income_o) io 
where  oo."date" >= io.prevdate and oo."date" <= io.nxtdate       




/*
QTY DT1 DT2
0 2001-03-22 00:00:00 2001-03-23 00:00:00
1500  2001-05-11 00:00:00 2001-09-13 00:00:00
22873.04  2001-03-24 00:00:00 2001-04-13 00:00:00
2300  2001-09-13 00:00:00 2001-10-02 00:00:00
3663  2001-03-23 00:00:00 2001-03-24 00:00:00
5640  2001-04-13 00:00:00 2001-05-11 00:00:00
*/


Задание: 128 (Shurgenz: 2006-08-05)

Определить лидера по сумме выплат в соревновании между каждой 
существующей парой пунктов с одинаковыми номерами из двух разных 
таблиц - outcome и outcome_o - на каждый день, когда 
осуществлялся прием вторсырья хотя бы на одном из них.
Вывод: Номер пункта, дата, текст:
- "once a day", если сумма выплат больше у фирмы с отчетностью один раз в день;
- "more than once a day", если - у фирмы с отчетностью несколько раз в день;
- "both", если сумма выплат одинакова.


select p.point, 
       p."date", 
       --nvl(ot.sum_day, 0), 
       --nvl(oo."out", 0),
       case when nvl(ot.sum_day, 0) < nvl(oo."out", 0) then 'once a day' 
            when nvl(ot.sum_day, 0) > nvl(oo."out", 0) then 'more than once a day' 
            when nvl(ot.sum_day, 0) = nvl(oo."out", 0) then 'both'   
       end lider
  from (select point, "date"
          from outcome o1 where exists (select 1 from outcome_o oo1 where o1.point=oo1.point)
        union
        select point, "date"
          from outcome_o oo2 where exists (select 1 from outcome o2 where o2.point=oo2.point)) p,
       (select point, "date", sum("out") sum_day
          from outcome
         group by point, "date"
         order by point, "date") ot,
       outcome_o oo
 where p.point = ot.point(+)
   and p."date" = ot."date"(+)
   and p.point = oo.point(+)
   and p."date" = oo."date"(+)
order by p.point, p."date"    

/*
POINT date  SUM_DAY
1 14.03.01 00:00:00,000000  15348
1 24.03.01 00:00:00,000000  7163
1 26.03.01 00:00:00,000000  1221
1 28.03.01 00:00:00,000000  2075
1 29.03.01 00:00:00,000000  4010
1 11.04.01 00:00:00,000000  3195,04
1 13.04.01 00:00:00,000000  4490
1 27.04.01 00:00:00,000000  3110
1 11.05.01 00:00:00,000000  2530
2 22.03.01 00:00:00,000000  2880
2 29.03.01 00:00:00,000000  7848
2 02.04.01 00:00:00,000000  2040
3 13.09.01 00:00:00,000000  2700
3 14.09.01 00:00:00,000000  1150
*/

/*
POINT date  SUM_DAY
1 14.03.01 00:00:00,000000  15348,00
2 22.03.01 00:00:00,000000  1440,00
1 24.03.01 00:00:00,000000  3663,00
1 26.03.01 00:00:00,000000  1221,00
1 28.03.01 00:00:00,000000  2075,00
1 29.03.01 00:00:00,000000  2004,00
2 29.03.01 00:00:00,000000  7848,00
2 02.04.01 00:00:00,000000  2040,00
1 11.04.01 00:00:00,000000  3195,04
1 13.04.01 00:00:00,000000  4490,00
1 27.04.01 00:00:00,000000  3110,00
1 11.05.01 00:00:00,000000  2530,00
3 13.09.01 00:00:00,000000  1500,00
3 14.09.01 00:00:00,000000  2300,00
3 16.09.02 00:00:00,000000  2150,00
*/


/*
POINT date  LIDER
1 2001-03-14 00:00:00 both
1 2001-03-24 00:00:00 more than once a day
1 2001-03-26 00:00:00 both
1 2001-03-28 00:00:00 both
1 2001-03-29 00:00:00 more than once a day
1 2001-04-11 00:00:00 both
1 2001-04-13 00:00:00 both
1 2001-04-27 00:00:00 both
1 2001-05-11 00:00:00 both
2 2001-03-22 00:00:00 more than once a day
2 2001-03-29 00:00:00 both
2 2001-04-02 00:00:00 both
3 2001-09-13 00:00:00 more than once a day
3 2001-09-14 00:00:00 once a day
3 2002-09-16 00:00:00 once a day
*/

Задание: 100 ($erges: 2009-06-05)

Написать запрос, который выводит все операции прихода и расхода из таблиц Income и Outcome в следующем виде:
дата, порядковый номер записи за эту дату, пункт прихода, сумма прихода, пункт расхода, сумма расхода.
При этом все операции прихода по всем пунктам, совершённые в течение одного дня, упорядочены по полю code, 
и так же все операции расхода упорядочены по полю code.
В случае, если операций прихода/расхода за один день было не равное количество, 
выводить NULL в соответствующих колонках на месте недостающих операций.


select dtt.dt, dtt.position, it.pi, it.si, ot.po, ot.so from 
(
select i."date" dt, row_number() over(partition by "date" order by code) position from income i
union 
select o."date" dt, row_number() over(partition by "date" order by code) position from outcome o
) dtt,
(
select i."date" dti,
       --i.code,
       row_number() over(partition by "date" order by code) position,
       i.point pi,
       i.inc si
  from income i
) it,
(
select o."date" dto,
       --o.code,
       row_number() over(partition by "date" order by code) position,
       o.point po,
       o."out" so
  from outcome o  
) ot
where dtt.dt=it.dti(+) and dtt.position = it.position(+)
      and dtt.dt=ot.dto(+) and dtt.position = ot.position(+)
order by dtt.dt



/*
D POS PI  SI  PO  SO
2001-03-14 00:00:00 1     1 15348
2001-03-22 00:00:00 1 1 15000 2 1440
2001-03-22 00:00:00 2 2 10000 2 1440
2001-03-22 00:00:00 3 1 15000   
2001-03-23 00:00:00 1 1 15000   
2001-03-24 00:00:00 1 1 3600  1 3663
2001-03-24 00:00:00 2 2 1500  1 3500
2001-03-24 00:00:00 3 2 1500    
2001-03-24 00:00:00 4 1 3400    
2001-03-26 00:00:00 1     1 1221
2001-03-28 00:00:00 1     1 2075
2001-03-29 00:00:00 1     1 2004
2001-03-29 00:00:00 2     2 7848
2001-03-29 00:00:00 3     1 2006
2001-04-02 00:00:00 1     2 2040
2001-04-11 00:00:00 1     1 3195.04
2001-04-13 00:00:00 1 1 5000  1 4490
2001-04-13 00:00:00 2 1 5000    
2001-04-27 00:00:00 1     1 3110
2001-05-11 00:00:00 1 1 4500  1 2530
2001-09-13 00:00:00 1 3 1350  3 1200
2001-09-13 00:00:00 2 3 1750  3 1500
2001-09-14 00:00:00 1     3 1150

*/

Задание: 99 (qwrqwr: 2013-03-01)

Рассматриваются только таблицы Income_o и Outcome_o. Известно, что прихода/расхода денег в воскресенье не бывает.
Для каждой даты прихода денег на каждом из пунктов определить дату инкассации по следующим правилам:
1. Дата инкассации совпадает с датой прихода, если в таблице Outcome_o нет записи о выдаче денег в эту дату на этом пункте.
2. В противном случае - первая возможная дата после даты прихода денег, которая не является воскресеньем и в Outcome_o 
не отмечена выдача денег сдатчикам вторсырья в эту дату на этом пункте.
Вывод: пункт, дата прихода денег, дата инкассации.


with dpr as
 (select i.point, i."date" dp, i."date" + nums dy
    from income_o i,
         (select 0 as nums
            from dual
          union
          select rownum nums
            from dual
          connect by rownum <= 31) n
   where 1 = 1
   /*order by i.point, i."date", dy*/)
select point, dp, min(dy) di
  from dpr
 where 1=1
   --обрасываем воскресенья
   --зависит от NLS параметров здесь ВС=1
   and to_number(to_char(dy, 'D')) != 1
   --and to_number(to_char(dy, 'D')) != 7
   --обрасываем дни расхода
   and not exists (select 1
          from outcome_o o
         where o.point = dpr.point
           and o."date" = dpr.dy)
 group by point, dp
 order by point, dp


select sysdate, to_number(to_char(sysdate, 'D')), to_number(to_char(sysdate-2, 'D')) from dual




/*
POINT DP  DI
1 2001-03-22 00:00:00 2001-03-22 00:00:00
1 2001-03-23 00:00:00 2001-03-23 00:00:00
1 2001-03-24 00:00:00 2001-03-27 00:00:00
1 2001-04-13 00:00:00 2001-04-14 00:00:00
1 2001-05-11 00:00:00 2001-05-12 00:00:00
2 2001-03-22 00:00:00 2001-03-23 00:00:00
2 2001-03-24 00:00:00 2001-03-24 00:00:00
3 2001-09-13 00:00:00 2001-09-15 00:00:00
3 2001-10-02 00:00:00 2001-10-02 00:00:00
*/


Задание: 81 (Serge I: 2011-11-25)

Из таблицы Outcome получить все записи за тот месяц (месяцы), с учетом года, в котором суммарное значение расхода (out) было максимальным.

with sum_by_mns as
 (select trunc(cast(o."date" as date), 'mm') mns, sum(o."out") summa
    from Outcome o
   group by trunc(cast(o."date" as date), 'mm'))
select *
  from Outcome
 where trunc(cast("date" as date), 'mm') in
       (select mns
          from sum_by_mns sbn
         where sbn.summa = (select max(summa) from sum_by_mns m_sbn))
/*
CODE  POINT date  out
10  2 2001-03-22 00:00:00 1440
11  2 2001-03-29 00:00:00 7848
13  1 2001-03-24 00:00:00 3500
14  2 2001-03-22 00:00:00 1440
15  1 2001-03-29 00:00:00 2006
1 1 2001-03-14 00:00:00 15348
2 1 2001-03-24 00:00:00 3663
3 1 2001-03-26 00:00:00 1221
4 1 2001-03-28 00:00:00 2075
5 1 2001-03-29 00:00:00 2004
*/

Задание: 69 (Serge I: 2011-01-06)

По таблицам Income и Outcome для каждого пункта приема найти остатки денежных средств на конец каждого дня,
в который выполнялись операции по приходу и/или расходу на данном пункте.
Учесть при этом, что деньги не изымаются, а остатки/задолженность переходят на следующий день.
Вывод: пункт приема, день в формате "dd/mm/yyyy", остатки/задолженность на конец этого дня.

with t_all as
 (select point, "date", inc, 0 AS "out"
    from income
  union all
  select point, "date", 0 AS inc, "out"
    from outcome)
SELECT t_all.point,
       TO_CHAR(t_all."date", 'DD/MM/YYYY') AS day,
       (select SUM(i.inc)
          from t_all i
         where i."date" <= t_all."date"
           and i.point = t_all.point) -
       (select SUM(i."out")
          from t_all i
         where i."date" <= t_all."date"
           and i.point = t_all.point) AS rem
  from t_all
 group by t_all.point, t_all."date"


Задание: 64 (Serge I: 2010-06-04)

Используя таблицы Income и Outcome, для каждого пункта приема определить дни, 
когда был приход, но не было расхода и наоборот.
Вывод: пункт, дата, тип операции (inc/out), денежная сумма за день.

with gr_i as
( 
select point, "date", 'inc' operation, sum(inc) money_sum from Income
group by point, "date"
), 
gr_o as
(
select point, "date", 'out' operation, sum("out") money_sum from Outcome
group by point, "date"
) 
select point, "date", operation, money_sum from gr_i
where not exists (select 1 from gr_o where gr_o.point=gr_i.point and gr_o."date"=gr_i."date")
union all
select point, "date", operation, money_sum from gr_o
where not exists (select 1 from gr_i where gr_o.point=gr_i.point and gr_o."date"=gr_i."date")

Задание: 62 (Serge I: 2003-02-15)

Посчитать остаток денежных средств на всех пунктах приема на начало дня 15/04/01 
для базы данных с отчетностью не чаще одного раза в день.

 select nvl(t1.prihod,0) - nvl(t2.rashod,0) ostatok from
 (select sum(i.INC) as prihod from Income_o i where i."date" < to_date('15/04/2001', 'DD/MM/YYYY')) t1, 
 (select sum(o."out") as rashod from Outcome_o o where o."date" < to_date('15/04/2001', 'DD/MM/YYYY')) t2 

Задание: 61 (Serge I: 2003-02-14)

Посчитать остаток денежных средств на всех пунктах приема 
для базы данных с отчетностью не чаще одного раза в день.

 select nvl(t1.prihod,0) - nvl(t2.rashod,0) ostatok from
 (select sum(i.INC) as prihod from Income_o i) t1, 
 (select sum(o."out") as rashod from Outcome_o o) t2 



Задание: 60 (Serge I: 2003-02-15)

Посчитать остаток денежных средств на начало дня 15/04/01 на каждом пункте 
приема для базы данных с отчетностью не чаще одного раза в день. Вывод: пункт, остаток.
Замечание. Не учитывать пункты, информации о которых нет до указанной даты.

 select t1.point, nvl(t1.prihod,0) - nvl(t2.rashod,0) ostatok from
 (select i.point, sum(i.INC) as prihod from Income_o i
 where i."date" < to_date('15/04/2001', 'DD/MM/YYYY')
 group by i.point) t1, 
 (select o.point, sum(o."out") as rashod from Outcome_o o
 where o."date" < to_date('15/04/2001', 'DD/MM/YYYY')
 group by o.point) t2 
 where t1.point=t2.point(+)

select i.point, i.INC from Income_o i
 where i."date" < to_date('15/04/2001', 'DD/MM/YYYY')

Задание: 59 (Serge I: 2003-02-15)

Посчитать остаток денежных средств на каждом пункте приема для базы данных
 с отчетностью не чаще одного раза в день. Вывод: пункт, остаток.

 select t1.point, nvl(t1.prihod,0) - nvl(t2.rashod,0) ostatok from
 (select i.point, sum(i.INC) as prihod from Income_o i
 group by i.point) t1, 
 (select o.point, sum(o."out") as rashod from Outcome_o o
 group by o.point) t2 
 where t1.point=t2.point(+)



Задание: 29 (Serge I: 2003-02-14)
В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день 
[т.е. первичный ключ (пункт, дата)], написать запрос с выходными данными 
(пункт, дата, приход, расход). Использовать таблицы Income_o и Outcome_o.

select point, "date", sum(inc), sum("out") from
(
select i.point, i."date", i.inc, null as "out" from income_o i
union all
select o.point, o."date", null as inc, o."out" from outcome_o o
) 
group by point, "date"
order by point, "date"

Задание: 30 (Serge I: 2003-02-14)

В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз
(первичным ключом в таблицах является столбец code), требуется получить таблицу, в которой каждому 
пункту за каждую дату выполнения операций будет соответствовать одна строка.
Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). 
Отсутствующие значения считать неопределенными (NULL).

select point, "date",  sum("out") as outcome, sum(inc) as income from
(
select i.point, i."date", null as "out", i.inc from income i
union all
select o.point, o."date", o."out", null as inc from outcome o
) 
group by point, "date"
order by point, "date"





Краткая информация о базе данных "Аэрофлот"

Схема БД состоит из четырех отношений:
Company (ID_comp, name)

select * from Company

ID_COMP	NAME
------------
1	Don_avia  
2	Aeroflot  
3	Dale_avia 
4	air_France
5	British_AW


Trip(trip_no, ID_comp, plane, town_from, town_to, time_out, time_in)

select * from trip

TRIP_NO ID_COMP PLANE TOWN_FROM TOWN_TO TIME_OUT  TIME_IN
------------------------------------------------------------
1100  4 Boeing      Rostov                    Paris                     01.01.00 14:30:00,000000  01.01.00 17:50:00,000000
1101  4 Boeing      Paris                     Rostov                    01.01.00 08:12:00,000000  01.01.00 11:45:00,000000
1123  3 TU-154      Rostov                    Vladivostok               01.01.00 16:20:00,000000  01.01.00 03:40:00,000000
1124  3 TU-154      Vladivostok               Rostov                    01.01.00 09:00:00,000000  01.01.00 19:50:00,000000
1145  2 IL-86       Moscow                    Rostov                    01.01.00 09:35:00,000000  01.01.00 11:23:00,000000
1146  2 IL-86       Rostov                    Moscow                    01.01.00 17:55:00,000000  01.01.00 20:01:00,000000
1181  1 TU-134      Rostov                    Moscow                    01.01.00 06:12:00,000000  01.01.00 08:01:00,000000
1182  1 TU-134      Moscow                    Rostov                    01.01.00 12:35:00,000000  01.01.00 14:30:00,000000
1187  1 TU-134      Rostov                    Moscow                    01.01.00 15:42:00,000000  01.01.00 17:39:00,000000
1188  1 TU-134      Moscow                    Rostov                    01.01.00 22:50:00,000000  01.01.00 00:48:00,000000
1195  1 TU-154      Rostov                    Moscow                    01.01.00 23:30:00,000000  01.01.00 01:11:00,000000
1196  1 TU-154      Moscow                    Rostov                    01.01.00 04:00:00,000000  01.01.00 05:45:00,000000
7771  5 Boeing      London                    Singapore                 01.01.00 01:00:00,000000  01.01.00 11:00:00,000000
7772  5 Boeing      Singapore                 London                    01.01.00 12:00:00,000000  01.01.00 02:00:00,000000
7773  5 Boeing      London                    Singapore                 01.01.00 03:00:00,000000  01.01.00 13:00:00,000000
7774  5 Boeing      Singapore                 London                    01.01.00 14:00:00,000000  01.01.00 06:00:00,000000
7775  5 Boeing      London                    Singapore                 01.01.00 09:00:00,000000  01.01.00 20:00:00,000000
7776  5 Boeing      Singapore                 London                    01.01.00 18:00:00,000000  01.01.00 08:00:00,000000
7777  5 Boeing      London                    Singapore                 01.01.00 18:00:00,000000  01.01.00 06:00:00,000000
7778  5 Boeing      Singapore                 London                    01.01.00 22:00:00,000000  01.01.00 12:00:00,000000
8881  5 Boeing      London                    Paris                     01.01.00 03:00:00,000000  01.01.00 04:00:00,000000
8882  5 Boeing      Paris                     London                    01.01.00 22:00:00,000000  01.01.00 23:00:00,000000

Passenger(ID_psg, name)

select * from Passenger

ID_PSG  NAME
-------------
1 Bruce Willis        
2 George Clooney      
3 Kevin Costner       
4 Donald Sutherland   
5 Jennifer Lopez      
6 Ray Liotta          
7 Samuel L. Jackson   
8 Nikole Kidman       
9 Alan Rickman        
10  Kurt Russell        
11  Harrison Ford       
12  Russell Crowe       
13  Steve Martin        
14  Michael Caine       
15  Angelina Jolie      
16  Mel Gibson          
17  Michael Douglas     
18  John Travolta       
19  Sylvester Stallone  
20  Tommy Lee Jones     
21  Catherine Zeta-Jones
22  Antonio Banderas    
23  Kim Basinger        
24  Sam Neill           
25  Gary Oldman         
26  Clint Eastwood      
27  Brad Pitt           
28  Johnny Depp         
29  Pierce Brosnan      
30  Sean Connery        
31  Bruce Willis        
37  Mullah Omar         


Pass_in_trip(trip_no, date, ID_psg, place)

select * from Pass_in_trip

TRIP_NO date  ID_PSG  PLACE
--------------------------------------
1100  29.04.03 00:00:00,000000  1 1a        
1123  05.04.03 00:00:00,000000  3 2a        
1123  08.04.03 00:00:00,000000  1 4c        
1123  08.04.03 00:00:00,000000  6 4b        
1124  02.04.03 00:00:00,000000  2 2d        
1145  05.04.03 00:00:00,000000  3 2c        
1181  01.04.03 00:00:00,000000  1 1a        
1181  01.04.03 00:00:00,000000  6 1b        
1181  01.04.03 00:00:00,000000  8 3c        
1181  13.04.03 00:00:00,000000  5 1b        
1182  13.04.03 00:00:00,000000  5 4b        
1187  14.04.03 00:00:00,000000  8 3a        
1188  01.04.03 00:00:00,000000  8 3a        
1182  13.04.03 00:00:00,000000  9 6d        
1145  25.04.03 00:00:00,000000  5 1d        
1187  14.04.03 00:00:00,000000  10  3d        
8882  06.11.05 00:00:00,000000  37  1a        
7771  07.11.05 00:00:00,000000  37  1c        
7772  07.11.05 00:00:00,000000  37  1a        
8881  08.11.05 00:00:00,000000  37  1d        
7778  05.11.05 00:00:00,000000  10  2a        
7772  29.11.05 00:00:00,000000  10  3a        
7771  04.11.05 00:00:00,000000  11  4a        
7771  07.11.05 00:00:00,000000  11  1b        
7771  09.11.05 00:00:00,000000  11  5a        
7772  07.11.05 00:00:00,000000  12  1d        
7773  07.11.05 00:00:00,000000  13  2d        
7772  29.11.05 00:00:00,000000  13  1b        
8882  13.11.05 00:00:00,000000  14  3d        
7771  14.11.05 00:00:00,000000  14  4d        
7771  16.11.05 00:00:00,000000  14  5d        
7772  29.11.05 00:00:00,000000  14  1c        


Таблица Company содержит идентификатор и название компании, осуществляющей перевозку пассажиров. 
Таблица Trip содержит информацию о рейсах: номер рейса, идентификатор компании, тип самолета, 
город отправления, город прибытия, время отправления и время прибытия. 
Таблица Passenger содержит идентификатор и имя пассажира. 
Таблица Pass_in_trip содержит информацию о полетах: номер рейса, дата вылета (день), идентификатор пассажира и место, 
на котором он сидел во время полета. При этом следует иметь в виду, что
- рейсы выполняются ежедневно, а длительность полета любого рейса менее суток; town_from <> town_to;
- время и дата учитывается относительно одного часового пояса;
- время отправления и прибытия указывается с точностью до минуты;
- среди пассажиров могут быть однофамильцы (одинаковые значения поля name, например, Bruce Willis);
- номер места в салоне – это число с буквой; число определяет номер ряда, буква (a – d) – место в ряду слева направо в алфавитном порядке;
- связи и ограничения показаны на схеме данных.


Задание: 142 (Serge I: 2003-08-28)

Среди пассажиров, летавших на самолетах только одного типа, определить тех, 
кто прилетал в один и тот же город не менее 2-х раз.
Вывести имена пассажиров.


WITH 
dsPsg AS
    (SELECT 
         p.ID_psg
     FROM 
         Pass_in_trip p
         INNER JOIN Trip t
         ON t.trip_no = p.trip_no 
     GROUP BY 
         p.ID_psg
     HAVING 
         MAX(t.plane) = MIN(t.plane) AND
	 COUNT(town_to) >   COUNT(DISTINCT town_to) 
)
SELECT
    p.name
FROM 
    dsPsg,
    Passenger p
WHERE    
    p.ID_psg = dsPsg.ID_psg 
GROUP BY 
    p.ID_psg,
    p.name



select (select name from passenger p where p.id_psg=ttt.id_psg) passname
from 
(
select distinct id_psg--, town_to, count(*)
from pass_in_trip pit, trip t
where pit.trip_no=t.trip_no
and id_psg in 
(
--пассажиры, летавшие на самолетах только одного типа
select id_psg/*, count(*)*/ from
(
select id_psg, plane
from pass_in_trip pit, trip t
where pit.trip_no=t.trip_no
group by id_psg, plane
) group by id_psg
having count(*)=1
)
group by id_psg, town_to
having count(*)>=2
) ttt


/*
name
Harrison Ford
Michael Caine
Mullah Omar
Nikole Kidman
*/


Задание: 141 (Serge I: 2017-11-03)

Для каждого из летавших пассажиров определить 
количество дней в апреле 2003 года, попавших 
в интервал между датами первого и последнего вылета пассажира включительно. 
Вывести имя пассажира и количество дней.



with tmp1 as
(
select pit.id_psg, 
 to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
         to_char(t.time_out, 'hh24:mi'),
         'dd.mm.yyyy hh24:mi') as date_out,
 case
   when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) > 0 then
    to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
            to_char(t.time_in, 'hh24:mi'),
            'dd.mm.yyyy hh24:mi')
   when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) < 0 then
    to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
            to_char(t.time_in, 'hh24:mi'),
            'dd.mm.yyyy hh24:mi') + 1
 end as date_in
from pass_in_trip pit, trip t
where pit.trip_no=t.trip_no
),
tmp2 as
(
select id_psg, min(date_out) minday, max(date_in) maxday from tmp1 ttt
 --where ttt.id_psg = 9
 group by id_psg
), 
tmp3 as
(
select id_psg,
       case
       when minday < to_date('01.04.2003','dd.mm.yyyy') 
       then to_date('01.04.2003','dd.mm.yyyy')  
       when (minday >= to_date('01.04.2003','dd.mm.yyyy')) and (minday < to_date('01.05.2003','dd.mm.yyyy')) 
       then minday 
       when minday > to_date('01.05.2003','dd.mm.yyyy')   
       then to_date('01.05.2003','dd.mm.yyyy')  
       end minday,
       case
       when maxday < to_date('01.04.2003','dd.mm.yyyy') 
       then to_date('01.04.2003','dd.mm.yyyy')            
       when (maxday >= to_date('01.04.2003','dd.mm.yyyy')) and (maxday < to_date('01.05.2003','dd.mm.yyyy')) 
       then maxday 
       when maxday > to_date('01.05.2003','dd.mm.yyyy')   
       then to_date('01.05.2003','dd.mm.yyyy')
       end maxday
from tmp2                
) select --id_psg, 
         (select name from passenger p where p.id_psg=tmp3.id_psg) passname,
         --maxday - minday dayss, 
         case 
           when (maxday - minday) >0 and ((maxday - minday) <> trunc(maxday - minday)) 
           then trunc(maxday - minday + 1) 
           else maxday - minday end days
         from tmp3   
         


/*
NAME  CNT
Alan Rickman  1
Bruce Willis  29
George Clooney  1
Harrison Ford 0
Jennifer Lopez  13
Kevin Costner 1
Kurt Russell  17
Michael Caine 0
Mullah Omar 0
Nikole Kidman 14
Ray Liotta  8
Russell Crowe 0
Steve Martin  0
*/


Задание: 133 (yuriy.rozhok: 2007-03-24)

Пусть имеется некоторое подмножество S множества целых чисел. 
Назовем "горкой с вершиной N" последовательность чисел из S, в которой числа, меньшие N, 
выстроены (слева направо без разделителей) сначала возрастающей цепочкой, а потом – убывающей цепочкой, 
и значением N между ними.
Например , для S = {1, 2, …, 10} горка с вершиной 5 представляется такой последовательностью: 123454321. 
При S, состоящем из идентификаторов всех компаний, для каждой компании построить "горку", 
рассматривая ее идентификатор в качестве вершины.
Считать идентификаторы положительными числами и учесть, что в базе нет данных, 
при которых количество цифр в "горке" может превысить 70.
Вывод: id_comp, "горка"

select 
from company



/*
ID_COMP	HILL
1	1
2	121
3	12321
4	1234321
5	123454321
*/


Задание: 131 (qwrqwr: 2010-09-24)

Выбрать из таблицы Trip такие города, названия которых содержат минимум 2 разные 
буквы из списка (a,e,i,o,u) и все имеющиеся в названии буквы из этого списка встречаются одинаковое число раз.

Подcказки к задаче №131
Следует иметь в виду, что функция LEN не учитывает концевые пробелы.

select town
/*t2.*,
cnt_sum/(case when cnt_in = 0 then 1 else cnt_in end)  drob,
trunc(cnt_sum/(case when cnt_in = 0 then 1 else cnt_in end)) celoe
*/
from
(
select t1.*,
       a+e+i+o+u cnt_sum,
       case when a>0 then 1 else 0 end +
       case when e>0 then 1 else 0 end +
       case when i>0 then 1 else 0 end +
       case when o>0 then 1 else 0 end +
       case when u>0 then 1 else 0 end cnt_in
  
from
( 
select town, 
       REGEXP_COUNT(t.town,'a') a,
       REGEXP_COUNT(t.town,'e') e,
       REGEXP_COUNT(t.town,'i') i,
       REGEXP_COUNT(t.town,'o') o,
       REGEXP_COUNT(t.town,'u') u,
       length(trim(t.town)) 
from
(
select town_from town from trip
union
select town_to town from trip
/*union
select 'Aaaaeeetttooouu' town from dual
union
select 'RRR' town from dual
union
select 'Aaaaeeetttooouuu' town from dual
union
select 'Aaaaааааeeeeeeetttooooooouuuuuuu' town from dual
union
select 'Aaaee' town from dual*/

) t 
) t1
) t2 where cnt_in >=2 
  and cnt_sum/(case when cnt_in = 0 then 1 else cnt_in end) = 
  trunc(cnt_sum/(case when cnt_in = 0 then 1 else cnt_in end))
  



select town from
(
select town,
       case when a=1 then 1 else 0 end +
       case when e=1 then 1 else 0 end +
       case when i=1 then 1 else 0 end +
       case when o=1 then 1 else 0 end +
       case when u=1 then 1 else 0 end cnt_in      
from
( 
select town, 
       case when instr(t.town,'a') > 0 then 1 else 0 end a,
       case when instr(t.town,'a') > 0 then 1 else 0 end a2,  
       case when instr(t.town,'e') > 0 then 1 else 0 end e,
       case when instr(t.town,'i') > 0 then 1 else 0 end i,
       case when instr(t.town,'o') > 0 then 1 else 0 end o,            
       case when instr(t.town,'u') > 0 then 1 else 0 end u
from
(
select town_from town from trip
union
select town_to town from trip
) t 
)
) where cnt_in >=2

/*
TOWN
PARIS
SINGAPORE
*/


where substr(t.town, 2,1) in ('a','e','i','o','u') 
        or substr(t.town, 3,1) in ('a','e','i','o','u')
        or substr(t.town, 4,1) in ('a','e','i','o','u')
        or substr(t.town, 5,1) in ('a','e','i','o','u')
        or substr(t.town, 6,1) in ('a','e','i','o','u')
        or substr(t.town, 7,1) in ('a','e','i','o','u')
        or substr(t.town, 8,1) in ('a','e','i','o','u')



select town, instr(t.town,'o'), instr(t.town,'o', -1), REGEXP_COUNT (t.town,'o') from
(
select town_from town from trip
union
select town_to town from trip
) t


select town, instr(t.town,'a')--, substr(t.town, 2,1), substr(t.town, 3,1), substr(t.town, 4,1) from
(
select town_from town from trip
union
select town_to town from trip
) t where substr(t.town, 2,1) in ('a','e','i','o','u') 
        or substr(t.town, 3,1) in ('a','e','i','o','u')
        or substr(t.town, 4,1) in ('a','e','i','o','u')
        or substr(t.town, 5,1) in ('a','e','i','o','u')
        or substr(t.town, 6,1) in ('a','e','i','o','u')
        or substr(t.town, 7,1) in ('a','e','i','o','u')
        or substr(t.town, 8,1) in ('a','e','i','o','u')


Задание: 126 (Serge I: 2015-04-17)

Для последовательности пассажиров, упорядоченных по id_psg, определить того,
кто совершил наибольшее число полетов, а также тех, кто находится в последовательности 
непосредственно перед и после него.
Для первого пассажира в последовательности предыдущим будет последний, 
а для последнего пассажира последующим будет первый.
Для каждого пассажира, отвечающего условию, вывести: имя, имя предыдущего пассажира, имя следующего пассажира. 

--(select name from passenger p where p.id_psg = grp.id_psg) passname,


select (select name from passenger p where p.id_psg = af.id_psg) passname,
       (select name from passenger p where p.id_psg = af.prev) prev,
       (select name from passenger p where p.id_psg = af.nxt) nxt
  from (select id_psg,
               case
                 when id_psg = (first_value(id_psg) over()) then
                  last_value(id_psg) over()
                 else
                  lag(id_psg) over(order by id_psg)
               end prev,
               case
                 when id_psg = (last_value(id_psg) over()) then
                  first_value(id_psg) over()
                 else
                  lead(id_psg) over(order by id_psg)
               end nxt,
               cnt_trip,
               max(cnt_trip) over() max_cnt_trip
          from (select p.id_psg, count(pit.trip_no) cnt_trip
                  from passenger p, pass_in_trip pit
                 where p.id_psg = pit.id_psg(+)
                 group by p.id_psg) grp) af
 where af.cnt_trip = af.max_cnt_trip


select pit.id_psg, count(pit.trip_no) cnt_trip
  from pass_in_trip pit 
group by pit.id_psg 
order by pit.id_psg

select p.id_psg, count(pit.trip_no) cnt_trip
  from passenger p, pass_in_trip pit 
  where p.id_psg = pit.id_psg(+)
group by p.id_psg  
order by p.id_psg


/*
psg prev  nxt
Michael Caine Steve Martin  Angelina Jolie
Mullah Omar Bruce Willis  Bruce Willis
*/


Задание: 124 (DimaN: 2004-03-01)

Среди пассажиров, которые пользовались услугами не менее двух авиакомпаний, найти тех, 
кто совершил одинаковое количество полётов самолетами каждой из этих авиакомпаний. 
Вывести имена таких пассажиров. 

with cte as
 (select ID_psg,
         ID_comp,
         count(ID_comp) over(partition by ID_psg, ID_comp order by ID_comp) c
    from Pass_in_trip
    join Trip
      on Trip.trip_no = Pass_in_trip.trip_no)

select (select name from Passenger where Passenger.ID_psg = cte.ID_psg) passname
  from cte
 group by ID_psg
having (count(distinct ID_comp) > = 2) and (max (c) = min (c))


with gr1 as
 (select pit.id_psg, t.id_comp, count(*) cnt_trip
    from pass_in_trip pit, trip t
   where pit.trip_no = t.trip_no
   group by pit.id_psg, t.id_comp),
gr2 as
 (
  --пассажиры, которые пользовались услугами не менее двух авиакомпаний
  select id_psg, count(*) cnt_comp
    from gr1
   group by id_psg
  having count(*) >= 2)
select (select name from passenger p where p.id_psg = gr3.id_psg) passname
  from (select id_psg,
               min(cnt_trip) min_cnt_trip,
               max(cnt_trip) max_cnt_trip
          from (select id_psg, id_comp, cnt_trip
                  from gr1
                 where id_psg in (select id_psg from gr2))
         group by id_psg) gr3
 where min_cnt_trip = max_cnt_trip

Задание: 122 (Serge I: 2003-08-28)

Считая, что первый пункт вылета является местом жительства, найти пассажиров, 
которые находятся вне дома. Вывод: имя пассажира, город проживания 

with pit1 as
 (select id_psg,
         town_from,
         date_out,
         min(date_out) over(partition by id_psg order by id_psg) as min_date_out,
         town_to,
         date_in,
         max(date_in) over(partition by id_psg order by id_psg) as max_date_in
    from (select pit.id_psg,
                 t.town_from,
                 to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                         to_char(t.time_out, 'hh24:mi'),
                         'dd.mm.yyyy hh24:mi') as date_out,
                 t.town_to,
                 case
                   when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) > 0 then
                    to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                            to_char(t.time_in, 'hh24:mi'),
                            'dd.mm.yyyy hh24:mi')
                   when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) < 0 then
                    to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                            to_char(t.time_in, 'hh24:mi'),
                            'dd.mm.yyyy hh24:mi') + 1
                 end as date_in
            from pass_in_trip pit, trip t
           where pit.trip_no = t.trip_no)),
psg_place_live as
 (select id_psg, town_from as place_live
    from pit1
   where date_out = min_date_out),
psg_place_now as
 (select id_psg, town_to as place_now from pit1 where date_in = max_date_in)
select (select name from passenger p where p.id_psg = l.id_psg) passname,
       l.place_live
  from psg_place_live l, psg_place_now n
 where l.id_psg = n.id_psg(+)
   and l.place_live <> n.place_now






with psg_place_live as
 (select id_psg, town_from as place_live
    from (select id_psg,
                 town_from,
                 date_out,
                 min(date_out) over(partition by id_psg order by id_psg) as min_date_out
            from (select pit.id_psg,
                         t.town_from,
                         to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                                 to_char(t.time_out, 'hh24:mi'),
                                 'dd.mm.yyyy hh24:mi') as date_out
                    from pass_in_trip pit, trip t
                   where pit.trip_no = t.trip_no))
   where date_out = min_date_out),
psg_place_now as
 (select id_psg, town_to as place_now
    from (select id_psg,
                 town_to,
                 date_in,
                 max(date_in) over(partition by id_psg order by id_psg) as max_date_in
            from (select pit.id_psg,
                         t.town_to,
                         case
                           when (CAST(t.time_in AS date) -
                                CAST(t.time_out AS date)) > 0 then
                            to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                                    to_char(t.time_in, 'hh24:mi'),
                                    'dd.mm.yyyy hh24:mi')
                           when (CAST(t.time_in AS date) -
                                CAST(t.time_out AS date)) < 0 then
                            to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                                    to_char(t.time_in, 'hh24:mi'),
                                    'dd.mm.yyyy hh24:mi') + 1
                         end as date_in
                    from pass_in_trip pit, trip t
                   where pit.trip_no = t.trip_no))
   where date_in = max_date_in)
select (select name from passenger p where p.id_psg = l.id_psg) passname,
       l.place_live
  from psg_place_live l, psg_place_now n
 where l.id_psg = n.id_psg(+)
   and l.place_live <> n.place_now



--  where ptdout.date_out
--  group by pit.id_psg, t.town_from
--  order by pit.id_psg, t.town_from




select *
  from pass_in_trip pit, trip t
 where pit.trip_no = t.trip_no





Задание: 120 (mslava: 2004-01-05)

Для каждой авиакомпании, самолеты которой перевезли хотя бы одного пассажира, 
вычислить с точностью до двух десятичных знаков средние величины времени 
нахождения самолетов в воздухе (в минутах). Также рассчитать указанные 
характеристики по всем летавшим самолетам (использовать слово 'TOTAL').
Вывод: компания, среднее арифметическое, среднее геометрическое, 
среднее квадратичное, среднее гармоническое.

Для справки:
среднее арифметическое = (x1 + x2 + ... + xN)/N
среднее геометрическое = (x1 * x2 * ... * xN)^(1/N)
среднее квадратичное = sqrt((x1^2 + x2^2 + ... + xN^2)/N)
среднее гармоническое = N/(1/x1 + 1/x2 + ... + 1/xN)

with pit_grp as
(
--Рейсы с группировкой по датам с количеством пассажиров
select pit.trip_no, pit."date", count(*) pass_cnt 
  from Pass_in_trip pit
group by pit.trip_no, pit."date"
), 
minuts_trips as
(
--Количество проведенных в воздухе минут по рейсам
select t.id_comp,
                case
                  when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) > 0 then
                   (CAST(t.time_in AS date) - CAST(t.time_out AS date)) * 24 * 60
                  when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) < 0 then
                   ((CAST(t.time_in AS date) + 1) - (CAST(t.time_out AS date))) * 24 * 60
                end minuts
from pit_grp pg, trip t
where pg.trip_no=t.trip_no
) 
select nvl((select name from company c where c.id_comp = mt.id_comp),'TOTAL') nm,
       round(avg(minuts),2) A_M,  
       round(exp(sum(ln(minuts))/count(*)),2) G_M,
       round(sqrt(avg(minuts*minuts)),2) Q_M,   
       round(1/avg(1/minuts),2) H_M  
       from minuts_trips mt
  group by rollup(mt.id_comp) 


with pit_grp as
(
--Рейсы с группировкой по датам с количеством пассажиров
select pit.trip_no, pit."date", count(*) pass_cnt 
  from Pass_in_trip pit
group by pit.trip_no, pit."date"
), 
minuts_trips as
(
--Количество проведенных в воздухе минут по рейсам
select t.id_comp,
                case
                  when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) > 0 then
                   (CAST(t.time_in AS date) - CAST(t.time_out AS date)) * 24 * 60
                  when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) < 0 then
                   ((CAST(t.time_in AS date) + 1) - (CAST(t.time_out AS date))) * 24 * 60
                end minuts
from pit_grp pg, trip t
where pg.trip_no=t.trip_no
) 
--Количество проведенных в воздухе минут по компаниям
select nvl((select name from company c where c.id_comp = mt.id_comp),'TOTAL') nm,
       --среднее арифметическое = (x1 + x2 + ... + xN)/N
       round(avg(minuts),2) A_M,  
       --среднее геометрическое = (x1 * x2 * ... * xN)^(1/N)
       round(exp(sum(ln(minuts))/count(*)),2) G_M,
       --среднее квадратичное = sqrt((x1^2 + x2^2 + ... + xN^2)/N)  
       round(sqrt(avg(minuts*minuts)),2) Q_M,   
       --среднее гармоническое = N/(1/x1 + 1/x2 + ... + 1/xN)
       round(1/avg(1/minuts),2) H_M  
       from minuts_trips mt
  group by rollup(mt.id_comp) 

/*--Количество проведенных в воздухе минут по рейсам с группировками по компаниям
select mt.id_comp, 
       minuts, 
       row_number() over (partition by id_comp order by id_comp) rn,
       count(*) over (partition by id_comp order by id_comp) cnt_trip,
       --среднее арифметическое = (x1 + x2 + ... + xN)/N       
       round(avg(minuts) over (partition by id_comp order by id_comp),2) A_M,  
       --среднее геометрическое = (x1 * x2 * ... * xN)^(1/N)
       
       --среднее квадратичное = sqrt((x1^2 + x2^2 + ... + xN^2)/N)  
       round(sqrt(avg(minuts*minuts) over (partition by id_comp order by id_comp)),2) Q_M,   
       --среднее гармоническое = N/(1/x1 + 1/x2 + ... + 1/xN)
       round(1/avg(1/minuts) over (partition by id_comp order by id_comp),2) H_M  
       from minuts_trips mt
  order by mt.id_comp
*/


/*
NM  A_M G_M Q_M H_M
Aeroflot  108 108 108 108
air_France  200 200 200 200
British_AW  525 367.01  597.75  188.76
Dale_avia 670 669.85  670.15  669.7
Don_avia  113.6 113.53  113.67  113.47
TOTAL 404.09  269.36  500.56  169.57
*/



Задание: 114 (Serge I: 2003-04-08)

Определить имена разных пассажиров, которым чаще других доводилось лететь на одном и том же месте. 
Вывод: имя и количество полетов на одном и том же месте.

Подcказки к задаче №114

Следует учесть, что один и тот же пассажир мог налетать 
одинаковое (максимальное) число раз на каждом из нескольких мест.

with pp as
(
select pit.id_psg, pit.place, count(*) cnt
from  Pass_in_trip pit 
group by pit.id_psg, pit.place  
),
pp1 as
(
select distinct id_psg, pp.cnt
from pp where pp.cnt=(select max(pup.cnt) from pp pup)
)
select p.name, pp1.cnt
from pp1, passenger p
where pp1.id_psg=p.id_psg




WITH pp AS
 (SELECT ID_psg, COUNT(*) as cnt FROM Pass_In_Trip GROUP BY ID_psg, place),
pp1 AS
 (SELECT DISTINCT ID_psg, cnt FROM pp WHERE cnt = (SELECT MAX(cnt) FROM pp))
SELECT name, cnt FROM pp1 JOIN Passenger p ON (pp1.ID_psg = p.ID_psg)


/*
name	NN
Bruce Willis	2
Mullah Omar	2
Nikole Kidman	2
*/

Задание: 110 (Serge I: 2003-12-24)

Определить имена разных пассажиров, когда-либо летевших рейсом, 
который вылетел в субботу, а приземлился в воскресенье.

select
	(select name from passenger where id_psg = pit.id_psg) as name
from pass_in_trip pit
join trip t
	on t.trip_no = pit.trip_no and t.time_in < t.time_out
where to_number(to_char(pit."date", 'D')) = 6
group by id_psg


select (select p.name from passenger p where dd.id_psg=p.id_psg) as name from
(
select pit.id_psg, 
       pit."date", 
       t.time_out, 
       t.time_in,
       to_date(to_char(pit."date", 'dd.mm.yyyy') 
       || ' ' || to_char(t.time_out, 'hh24:mi'),
       'dd.mm.yyyy hh24:mi') as date_out,
       case 
       when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) > 0 
          then to_date(to_char(pit."date", 'dd.mm.yyyy') 
                 || ' ' || to_char(t.time_in, 'hh24:mi'),
                'dd.mm.yyyy hh24:mi')
       when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) < 0 
          then to_date(to_char(pit."date", 'dd.mm.yyyy') 
                 || ' ' || to_char(t.time_in, 'hh24:mi'),
                'dd.mm.yyyy hh24:mi')+1
       end as date_in        
  from Pass_in_trip pit, trip t 
 where pit.trip_no = t.trip_no
 )dd
 -- where to_number(to_char(dd.date_out, 'D')) = 6
-- and to_number(to_char(dd.date_in, 'D')) = 7
 --зависит от NLS параметров здесь СБ=7 ВС=1 
 where trim(to_char(dd.date_out,'DAY','nls_date_language = AMERICAN'))='SATURDAY' 
 and trim(to_char(dd.date_in,'DAY','nls_date_language = AMERICAN'))='SUNDAY' 
 group by dd.id_psg

select date_out, dd.date_in, to_char(dd.date_out,'DAY','nls_date_language = AMERICAN'),
 to_char(dd.date_in,'DAY','nls_date_language = AMERICAN') from 
( 
select pit.id_psg, 
       pit."date", 
       t.time_out, 
       t.time_in,
       to_date(to_char(pit."date", 'dd.mm.yyyy') 
       || ' ' || to_char(t.time_out, 'hh24:mi'),
       'dd.mm.yyyy hh24:mi') as date_out,
       case 
       when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) > 0 
          then to_date(to_char(pit."date", 'dd.mm.yyyy') 
                 || ' ' || to_char(t.time_in, 'hh24:mi'),
                'dd.mm.yyyy hh24:mi')
       when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) < 0 
          then to_date(to_char(pit."date", 'dd.mm.yyyy') 
                 || ' ' || to_char(t.time_in, 'hh24:mi'),
                'dd.mm.yyyy hh24:mi')+1
       end as date_in        
  from Pass_in_trip pit, trip t 
 where pit.trip_no = t.trip_no
) dd



     
select sysdate, to_char(sysdate-2,'DAY','nls_date_language = AMERICAN') dd,  
to_char(sysdate-1,'DAY','nls_date_language = AMERICAN') ddd from dual

select 
sysdate,
to_char(sysdate-2,'DAY','nls_date_language = AMERICAN'),
to_char(sysdate-1,'DAY','nls_date_language = AMERICAN')
from dual



/*
    when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) > 0 then  (CAST(t.time_in AS date)-CAST(t.time_out AS date))*24*60
    when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) < 0 then ((CAST(t.time_in AS date)+1)-(CAST(t.time_out AS date)))*24*60
    end diff_time   

                            and pmd.min_dt_tm_out =
                                to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                                        to_char(t.time_out, 'hh24:mi'),
                                        'dd.mm.yyyy hh24:mi'))
*/


/*
  --зависит от NLS параметров здесь ВС=1
   and to_number(to_char(dy, 'D')) != 1
   --and to_number(to_char(dy, 'D')) != 7
*/


/*
NAME
Kevin Costner
Kurt Russell
*/


Задание: 107 (VIG: 2003-09-01)

Для пятого по счету пассажира из числа вылетевших из Ростова в апреле 2003 года определить компанию, номер рейса и дату вылета.
Замечание. Считать, что два рейса одновременно вылететь из Ростова не могут.

select (select c.name from company c where c.id_comp = a.id_comp) compname,
       trip_no,
       "date"
  from (select t.id_comp,
               pit.trip_no,
               pit."date",
               --t.time_out,
               row_number() over(order by pit."date", t.time_out) num_pass
          from Pass_in_trip pit, trip t
         where pit.trip_no = t.trip_no
           and t.town_from = 'Rostov'
           and trunc(cast(pit."date" as date), 'mm') =
               to_date('01.04.2003', 'dd.mm.yyyy')
         /*order by pit."date", t.time_out*/) a
 where num_pass = 5


select pit."date", trunc(cast(pit."date" as date),'mm') from Pass_in_trip pit


Задание: 103 (qwrqwr: 2013-05-17)

Выбрать три наименьших и три наибольших номера рейса. Вывести их в шести столбцах одной строки, 
расположив в порядке от наименьшего к наибольшему.
Замечание: считать, что таблица Trip содержит не менее шести строк.

WITH 
e AS (
select 'min' || rn as clmn, trip_no
  from (select rownum rn, trip_no
          from trip
         where rownum <= 3
         order by trip_no asc)
union
select 'max' || rn as clmn, trip_no
  from (select rownum rn, trip_no
          from trip
         where rownum <= 3
         order by trip_no desc)
)
SELECT 
   (SELECT trip_no FROM e WHERE clmn='min1') min1,
   (SELECT trip_no FROM e WHERE clmn='min2') min2,
   (SELECT trip_no FROM e WHERE clmn='min3') min3,
   (SELECT trip_no FROM e WHERE clmn='max3') max3,
   (SELECT trip_no FROM e WHERE clmn='max2') max2,
   (SELECT trip_no FROM e WHERE clmn='max1') max1
from dual



Select min(t.trip_no),min(tt.trip_no),min(ttt.trip_no),max(t.trip_no),max(tt.trip_no),max(ttt.trip_no)
from trip t, trip tt, trip ttt
where tt.trip_no > t.trip_no and ttt.trip_no > tt.trip_no

Select *
from trip t, trip tt, trip ttt
where tt.trip_no > t.trip_no and ttt.trip_no > tt.trip_no



select * from
(
select 'min' || rn as clmn, trip_no
  from (select rownum rn, trip_no
          from trip
         where rownum <= 3
         order by trip_no asc)
union
select 'max' || rn as clmn, trip_no
  from (select rownum rn, trip_no
          from trip
         where rownum <= 3
         order by trip_no desc)
) order by trip_no




select * from
(
select 'min' || rn as clmn, rn, trip_no
  from (select rownum rn, trip_no
          from trip
         where rownum <= 3
         order by trip_no asc)
union
select 'max' || rn as clmn, rn, trip_no
  from (select rownum rn, trip_no
          from trip
         where rownum <= 3
         order by trip_no desc)
) order by trip_no



with min_trip_no as
(
select rownum rn, trip_no from trip
where rownum<=3
order by trip_no asc
),
max_trip_no as
(
select rownum rn, trip_no from trip
where rownum<=3
order by trip_no desc
)
select 'min'||rn as clmn, rn, trip_no from min_trip_no
union
select 'max'||rn as clmn, rn, trip_no from max_trip_no

/*select case when rn=1 then trip_no end min1,
       case when rn=2 then trip_no end min2,  
       case when rn=3 then trip_no end min3  
from min_trip_no*/

select case when rn=3 then trip_no end max3,
       case when rn=2 then trip_no end max2,  
       case when rn=1 then trip_no end max1  
from max_trip_no
        
/*
MIN1  MIN2  MIN3  MAX3  MAX2  MAX1
1100  1101  1123  7778  8881  8882
*/


Задание: 102 (Serge I: 2003-04-29)

Определить имена разных пассажиров, которые летали
только между двумя городами (туда и/или обратно).


select (select p1.name from passenger p1 where p1.id_psg = p.id_psg) pname from 
(
  --туда
  select p.id_psg, t.town_from, t.town_to
    from Pass_in_trip p, trip t
   where p.trip_no = t.trip_no
  group by p.id_psg, t.town_from, t.town_to
  union 
  --обратно
  select p.id_psg, t.town_to, t.town_from
    from Pass_in_trip p, trip t
   where p.trip_no = t.trip_no
  group by p.id_psg, t.town_from, t.town_to
) p group by id_psg 
  having count(*)=2

--Феноменально!
select
	(select name from passenger where pit.id_psg = id_psg) as name
from pass_in_trip pit
join trip t
	on t.trip_no = pit.trip_no
group by pit.id_psg
having count(distinct case when town_from >  town_to then concat(town_from, town_to) else concat(town_to, town_from) end) = 1


--Феноменально!
select
	distinct (select name from passenger where pit.id_psg = id_psg) as name,
  case when town_from >  town_to then concat(town_from, town_to) else concat(town_to, town_from) end concat_town
from pass_in_trip pit
join trip t
	on t.trip_no = pit.trip_no




Задание: 95 (qwrqwr: 2013-02-08)
На основании информации из таблицы Pass_in_Trip, для каждой авиакомпании определить:
1) количество выполненных перелетов;
2) число использованных типов самолетов;
3) количество перевезенных различных пассажиров;
4) общее число перевезенных компанией пассажиров.
Вывод: Название компании, 1), 2), 3), 4).

 
select t.id_comp, trip_psngr_cnt.cnt from trip t,
(
--количество перевезенных различных пассажиров по рейсам 
select trip_no, count(*) cnt  from 
(--количество рейсов которые летал пассажир по рейсам
select trip_no, id_psg, count(*) cnt1
 from Pass_in_Trip
group by trip_no, id_psg
) group by trip_no
) trip_psngr_cnt
where t.trip_no=trip_psngr_cnt.trip_no
group by t.id_comp


with trip_dt_ps_cnt as
 (
  --количество перевез. пассажиров по рейсам и датам
  select trip_no, "date", count(*) cnt_trip_dt
    from Pass_in_Trip
   group by trip_no, "date"),
trip_cnt as
 (
  --количество выполненных перелетов по рейсам 
  select trip_no, count(*) cnt_trip from trip_dt_ps_cnt group by trip_no),
trip_cnt_compn as
 (
  --количество выполненных перелетов для компании
  select t.id_comp, sum(tc.cnt_trip) FLIGHTS
    from trip_cnt tc, trip t
   where tc.trip_no = t.trip_no
   group by t.id_comp),
type_plns_cnt_compn as
 ( --Группировка по компаниям и количеству типов самолетов
  select id_comp, count(*) PLANES
    from ( --Группировка по компаниям и использованным самолетам
           select t.plane, t.id_comp
             from trip t,
                   --количество перевез. пассажиров по рейсам и датам
                   trip_dt_ps_cnt trips_days
            where t.trip_no = trips_days.trip_no
            group by t.plane, t.id_comp)
   group by id_comp),
pass_cnt as
 (
  --количество перевез. пассажиров по рейсам 
  select trip_no, sum(cnt_trip_dt) cnt_pass
    from trip_dt_ps_cnt
   group by trip_no),
pass_cnt_compn as
 ( --количество перевез. пассажиров по компаниям
  select t.id_comp, sum(p.cnt_pass) TOTAL_PSNGRS
    from pass_cnt p, trip t
   where p.trip_no = t.trip_no
   group by t.id_comp),
pass_dif_cnt_compn as
 (select id_comp, count(*) DIFF_PSNGRS
    from (select t.id_comp, pit.id_psg
            from Pass_in_Trip pit, trip t
           where pit.trip_no = t.trip_no
           group by t.id_comp, pit.id_psg)
   group by id_comp),
model_cnt as
 (
  --количество выполненных перелетов по рейсам 
  select trip_no, count(*) cnt_trip from trip_dt_ps_cnt group by trip_no)
--select * from model_cnt   
select c.name, t.FLIGHTS, tp.PLANES, pd.DIFF_PSNGRS, p.TOTAL_PSNGRS
  from company             c,
       trip_cnt_compn      t,
       pass_cnt_compn      p,
       pass_dif_cnt_compn  pd,
       type_plns_cnt_compn tp
 where c.id_comp = t.id_comp
   and c.id_comp = tp.id_comp
   and c.id_comp = pd.id_comp
   and c.id_comp = p.id_comp
 order by c.name


/*
COMPANY_NAME  FLIGHTS PLANES  DIFF_PSNGRS TOTAL_PSNGRS
Aeroflot  2 1 2 2
air_France  1 1 1 1
British_AW  12  1 6 16
Dale_avia 3 1 4 4
Don_avia  5 1 6 9
*/



Задание: 94 (Serge I: 2003-04-09)
Для семи последовательных дней, начиная от минимальной даты, 
когда из Ростова было совершено максимальное число рейсов, 
определить число рейсов из Ростова.
Вывод: дата, количество рейсов


with dt_trip_Rst 
as
(
-- Рейсы из Ростова
select gpit.trip_no, gpit."date", t.town_from, t.town_to
  from ( --рейсы по датам
         select pit.trip_no, pit."date"
           from Pass_in_trip pit
          group by pit.trip_no, pit."date") gpit,
        trip t
where gpit.trip_no = t.trip_no
and t.town_from='Rostov'
),
dt_cnt_trip_Rst as 
(
--Количество рейсов из Ростова по датам
select "date", count(*) cnt_trip 
from dt_trip_Rst
group by "date"
),
min_dt_tbl as
(
--минимальная дата, когда из Ростова было совершено максимальное число рейсов
select /*+ materialize*/ min("date") min_dt from dt_cnt_trip_Rst dctR
where dctR.cnt_trip = (select max(dctR1.cnt_trip) from dt_cnt_trip_Rst dctR1)
),
seven_days as
(
select cast(min_dt as date) dt from min_dt_tbl
union 
select cast(min_dt as date)+1 dt from min_dt_tbl
union 
select cast(min_dt as date)+2 dt from min_dt_tbl
union
select cast(min_dt as date)+3 dt from min_dt_tbl
union
select cast(min_dt as date)+4 dt from min_dt_tbl
union
select cast(min_dt as date)+5 dt from min_dt_tbl
union
select cast(min_dt as date)+6 dt from min_dt_tbl
)
select seven_days.dt, nvl(days.cnt,0) cnt from seven_days, 
(
select R."date", count(*) cnt from dt_trip_Rst R
group by R."date"
) days where seven_days.dt = days."date"(+)
order by seven_days.dt







with dt_trip_Rst 
as
(
-- Рейсы из Ростова
select gpit.trip_no, gpit."date", t.town_from, t.town_to
  from ( --рейсы по датам
         select pit.trip_no, pit."date"
           from Pass_in_trip pit
          group by pit.trip_no, pit."date") gpit,
        trip t
where gpit.trip_no = t.trip_no
and t.town_from='Rostov'
),
dt_cnt_trip_Rst as 
(
--Количество рейсов из Ростова по датам
select "date", count(*) cnt_trip 
from dt_trip_Rst
group by "date"
),
min_dt_max_cnt_trip_Rst as
(
--минимальная дата, когда из Ростова было совершено максимальное число рейсов
select /*+ materialize*/ min("date") min_dt from dt_cnt_trip_Rst dctR
where dctR.cnt_trip = (select max(dctR1.cnt_trip) from dt_cnt_trip_Rst dctR1)
),
seven_days as
(
select cast(min_dt as date) dt from min_dt_max_cnt_trip_Rst
union 
select cast(min_dt as date)+1 dt from min_dt_max_cnt_trip_Rst
union 
select cast(min_dt as date)+2 dt from min_dt_max_cnt_trip_Rst
union
select cast(min_dt as date)+3 dt from min_dt_max_cnt_trip_Rst
union
select cast(min_dt as date)+4 dt from min_dt_max_cnt_trip_Rst
union
select cast(min_dt as date)+5 dt from min_dt_max_cnt_trip_Rst
union
select cast(min_dt as date)+6 dt from min_dt_max_cnt_trip_Rst
)
select seven_days.dt, nvl(days.cnt,0) cnt from seven_days, 
(
select R."date", count(*) cnt from dt_trip_Rst R
where R."date" >= (select min_dt from min_dt_max_cnt_trip_Rst)
      and cast(R."date" as date) < (select cast(min_dt as date)+7 from min_dt_max_cnt_trip_Rst)
      group by R."date"
) days where seven_days.dt = days."date"(+)
order by seven_days.dt

Задание: 93 (Serge I: 2003-06-05)

Для каждой компании, перевозившей пассажиров, подсчитать время, которое провели в полете самолеты с пассажирами.
Вывод: название компании, время в минутах.

select (select c.name from company c where c.id_comp = r.id_comp) compname,
       sum(minuts)
  from (
        --рейсы с длительностью ы минутах 
        select t.id_comp,
                case
                  when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) > 0 then
                   (CAST(t.time_in AS date) - CAST(t.time_out AS date)) * 24 * 60
                  when (CAST(t.time_in AS date) - CAST(t.time_out AS date)) < 0 then
                   ((CAST(t.time_in AS date) + 1) - (CAST(t.time_out AS date))) * 24 * 60
                end minuts
          from ( --рейсы по датам
                 select pit.trip_no, pit."date"
                   from Pass_in_trip pit
                  group by pit.trip_no, pit."date") gpit,
                trip t
         where gpit.trip_no = t.trip_no) r
 group by id_comp

--рейсы по датам
select pit.trip_no, pit."date" from Pass_in_trip pit
group by pit.trip_no, pit."date"

/*
COMPANY MINUTES
Aeroflot  216
air_France  200
British_AW  6300
Dale_avia 2010
Don_avia  568

*/

Задание: 88 (Serge I: 2003-04-29)

Среди тех, кто пользуется услугами только одной компании, определить имена разных пассажиров, летавших чаще других.
Вывести: имя пассажира, число полетов и название компании.

with pass_comp_cnt_trip as
 (select pit.id_psg,
         min(t.id_comp) id_comp,
         count(1) cnt_trip,
         --count(pit.trip_no) count_trip,
         --получаем максимум для определения летавших чаще других
         max(count(pit.trip_no)) over() max_count_trip
    from pass_in_trip pit
    join trip t
      on pit.trip_no = t.trip_no
   group by pit.id_psg
   --это условие позволяет нам выбрать пассажиров пользующихся услугами только одной компании
  having min(t.id_comp) = max(t.id_comp))
select p.name passname, pcct.cnt_trip, c.name companyname
  from pass_comp_cnt_trip pcct, passenger p, company c
 where pcct.id_psg = p.id_psg
   and pcct.id_comp = c.id_comp
   and pcct.cnt_trip = pcct.max_count_trip




with pass_comp_cnt_trip as
 (
  --Группировка Пассажиры - Авиакомпании, c подсчетом рейсов
  select pit.id_psg, t.id_comp, count(*) cnt_trip, max(count(pit.trip_no)) over() max_trip
    from Pass_in_trip pit, trip t
   where pit.trip_no = t.trip_no
   group by pit.id_psg, t.id_comp),
passr_only_one_comp as
 (
  --Пассажиры, пользующиеся услугами только одной компании
  --Пассажир - авиакомпания, группировка пассажирам
  select id_psg, count(ID_comp) cnt_comp
    from pass_comp_cnt_trip
   group by id_psg
  having count(ID_comp)=1
  )
--  select * from passr_only_one_comp
select p.name passname, pcct.cnt_trip, c.name companyname
  from pass_comp_cnt_trip pcct, passenger p, company c
 where pcct.id_psg = p.id_psg
   and pcct.id_comp = c.id_comp
   and pcct.id_psg in (select id_psg from passr_only_one_comp)
   and pcct.cnt_trip = pcct.max_trip
       --(select max(pcct1.cnt_trip) from pass_comp_cnt_trip pcct1)


with max_tbl as (
Select ID_psg, 
	max(ID_comp) ID_comp, 
	count(pit.trip_no) trip_Qty, 
	max(count(pit.trip_no)) over() max_trip
from Pass_in_trip pit
join Trip tr on tr.trip_no=pit.trip_no
group by ID_psg
having max(ID_comp)=min(ID_comp))

select (select name from Passenger where ID_psg=m.ID_psg) name,	trip_Qty, 
       (select name from Company where ID_comp=m.ID_comp) Company 
from max_tbl m
where trip_Qty=max_trip


WITH dsPsg AS
(SELECT p.ID_psg,
        --COUNT(DISTINCT t.ID_comp) countComp,
        COUNT(*) trip_Qty,
        max(t.ID_comp) idComp
 FROM Trip t, Pass_in_trip p
 WHERE p.trip_no = t.trip_no
 GROUP BY p.ID_psg
 HAVING COUNT(DISTINCT t.ID_comp) = 1
)
SELECT p.name, dsPsg.trip_Qty, c.name
FROM dsPsg, Company c, Passenger p
WHERE dsPsg.ID_psg = p.ID_psg and
      dsPsg.idComp = c.ID_Comp and
      dsPsg.trip_Qty = (SELECT max(dsPsg.trip_Qty)
                        FROM dsPsg
                       )

select   *
         --p.id_psg,
         --count(distinct t.id_comp) countcomp,
         --count(*) cnt_trip,
         --max(t.id_comp) idcomp
    from trip t, pass_in_trip p
   where p.trip_no = t.trip_no
   group by p.id_psg
  --having count(distinct t.id_comp) = 1

/*
ID_PSG  IDCOMP
6 3
12  5
5 2
8 1
1 4
3 3
2 3
14  5
13  5
9 1
10  5
11  5
37  5

*/

--Пассажир - авиакомпания, группировка по рейсам 
select pit.id_psg, t.id_comp, c.name, count(*) cnt_trip
from Pass_in_trip pit, trip t, company c
where pit.trip_no = t.trip_no
      and t.id_comp=c.id_comp
group by pit.id_psg, t.id_comp, c.name


/*
NAME  TRIP_QTY  COMPANY
Michael Caine 4 British_AW
Mullah Omar 4 British_AW
*/

Задание: 87 (Serge I: 2003-08-28)

Считая, что пункт самого первого вылета пассажира является местом жительства, найти не москвичей, 
которые прилетали в Москву более одного раза.
Вывод: имя пассажира, количество полетов в Москву

select name, cnt
  from Passenger p,
       (select tt1.id_psg, count(*) cnt
          from Pass_in_trip tt1, trip tt2
         where tt1.trip_no = tt2.trip_no
           and tt2.town_to = 'Moscow'
           and tt1.id_psg in
               ( --Пассажиры не москвичи
                select id_psg
                  from (
                         --пассажир, пункт самого первого вылета
                         select pit.id_psg, t.town_from as place_live
                           from (
                                  --пассажир, минимальная дата, время вылета
                                  select id_psg,
                                          min(to_date(to_char("date", 'dd.mm.yyyy') || ' ' ||
                                                      to_char(t2.time_out, 'hh24:mi'),
                                                      'dd.mm.yyyy hh24:mi')) min_dt_tm_out
                                    from Pass_in_trip t1, trip t2
                                   where t1.trip_no = t2.trip_no
                                   group by id_psg) pmd,
                                 Pass_in_trip pit,
                                 trip t
                          where pmd.id_psg = pit.id_psg
                            and pit.trip_no = t.trip_no
                            and pmd.min_dt_tm_out =
                                to_date(to_char(pit."date", 'dd.mm.yyyy') || ' ' ||
                                        to_char(t.time_out, 'hh24:mi'),
                                        'dd.mm.yyyy hh24:mi'))
                --"не москвич"
                 where place_live != 'Moscow')
         group by tt1.id_psg
        having count(*) > 1) tbl_cnt
 where p.id_psg = tbl_cnt.id_psg


--пассажир, минимальная дата, время вылета
select id_psg,
         min(to_date(to_char("date", 'dd.mm.yyyy') ||' '|| to_char(t2.time_out, 'hh24:mi'),'dd.mm.yyyy hh24:mi')) min_dt_tm_out
  from Pass_in_trip t1, trip t2
 where t1.trip_no = t2.trip_no
group by id_psg


select * 
from Pass_in_trip pit, trip t
where pit.trip_no = t.trip_no
and pit.id_psg=8
      
Задание: 84 (Serge I: 2003-06-05)

Для каждой компании подсчитать количество перевезенных пассажиров (если они были в этом месяце) 
по декадам апреля 2003. При этом учитывать только дату вылета.
Вывод: название компании, количество пассажиров за каждую декаду


select 
 cp.name,
 sum(case
       when (cast("date" as date)) >= to_date('01.04.2003', 'dd.mm.yyyy') and
            cast("date" as date) < to_date('11.04.2003', 'dd.mm.yyyy') then
        1
       else
        0
     end) as N_1_10,
 sum(case
       when (cast("date" as date)) >= to_date('11.04.2003', 'dd.mm.yyyy') and
            cast("date" as date) < to_date('21.04.2003', 'dd.mm.yyyy') then
        1
       else
        0
     end) as N_11_21,
 sum(case
       when (cast("date" as date)) >= to_date('21.04.2003', 'dd.mm.yyyy') and
            cast("date" as date) <= to_date('30.04.2003', 'dd.mm.yyyy') then
        1
       else
        0
     end) as N_21_30

  from Pass_in_trip pit, trip t, Company cp
 where pit.trip_no = t.trip_no
   and t.id_comp = cp.id_comp
      --рейсы только в апреле 2003
 and trunc(CAST(pit."date" AS date),'mm') = to_date('01.04.2003', 'dd.mm.yyyy')
 group by cp.name

--MSSQL
SELECT C.name, A.N_1_10, A.N_11_21, A.N_21_30
FROM (SELECT T.ID_comp,
       SUM(CASE WHEN DAY(P.date) < 11 THEN 1 ELSE 0 END) AS N_1_10,
       SUM(CASE WHEN (DAY(P.date) > 10 AND DAY(P.date) < 21) THEN 1 ELSE 0 END) AS N_11_21,
       SUM(CASE WHEN DAY(P.date) > 20 THEN 1 ELSE 0 END) AS N_21_30
      FROM Trip AS T JOIN
       Pass_in_trip AS P ON T.trip_no = P.trip_no AND CONVERT(char(6), P.date, 112) = '200304'
      GROUP BY T.ID_comp
      ) AS A JOIN
 Company AS C ON A.ID_comp = C.ID_comp


select 
cp.name, count(*)
from  Pass_in_trip pit, trip t, Company cp
 where pit.trip_no = t.trip_no
 and t.id_comp=cp.id_comp
 --рейсы только апреля 2003
 --and trunc("date" ,'mm')='01.04.2003'
group by cp.name


--Количество перевезенных 
--пассажиров за апрель 2003
--по авиакомпаниям
select 
cp.name, count(*) 
from  Pass_in_trip pit, trip t, Company cp
 where pit.trip_no = t.trip_no
 and t.id_comp=cp.id_comp
 --рейсы только апреля 2003
 and trunc(CAST(pit."date" AS date),'mm') = to_date('01.04.2003', 'dd.mm.yyyy')
group by cp.name
 
select * from v$parameter ppp
where  ppp.NAME like '%compatible%'


/*
NAME  1-10  11-20 21-30
Aeroflot  1 0 1
air_France  0 0 1
Dale_avia 4 0 0
Don_avia  4 5 0
*/

Задание: 79 (Serge I: 2003-04-29)

Определить пассажиров, которые больше других времени провели в полетах.
Вывод: имя пассажира, общее время в минутах, проведенное в полетах

with g as
(
select id_psg, sum(diff_time) as minutes1 from
(
select p.id_psg,
       p.name,
       case 
    when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) > 0 then  (CAST(t.time_in AS date)-CAST(t.time_out AS date))*24*60
    when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) < 0 then ((CAST(t.time_in AS date)+1)-(CAST(t.time_out AS date)))*24*60
    end diff_time       
  from Passenger p, Pass_in_trip pit, trip t
 where p.id_psg = pit.id_psg
   and pit.trip_no = t.trip_no
 )
 group by id_psg 
) 
 select p1.name, g.minutes1 from Passenger p1, g
 where p1.id_psg=g.id_psg and g.minutes1 in (select max(g1.minutes1) from g g1)


Задание: 77 (Serge I: 2003-04-09)

Определить дни, когда было выполнено максимальное число рейсов из
Ростова ('Rostov'). Вывод: число рейсов, дата.

with dt_cnt as
(
select "date" as dt, count(*) cnt from 
(
--рейсы по датам
select t.trip_no, "date" from trip t, Pass_in_trip pit
where t.trip_no=pit.trip_no
      and t.town_from='Rostov'
group by t.trip_no, "date"      
) group by "date"     
)
select cnt, dt from dt_cnt where cnt=(select max(cnt) from dt_cnt)

select * from trip t, Pass_in_trip pit
where t.trip_no=pit.trip_no
      and t.town_from='Rostov'



Задание: 76 (Serge I: 2003-08-28)
Определить время, проведенное в полетах, для пассажиров, летавших всегда на разных местах. Вывод: имя пассажира, время в минутах.


select p1.name, g.minutes1 from Passenger p1,
(select id_psg, sum(diff_time) as minutes1 from
(
select p.id_psg,
       p.name,
       case 
    when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) > 0 then  (CAST(t.time_in AS date)-CAST(t.time_out AS date))*24*60
    when (CAST(t.time_in AS date)-CAST(t.time_out AS date)) < 0 then ((CAST(t.time_in AS date)+1)-(CAST(t.time_out AS date)))*24*60
    end diff_time       
  from Passenger p, Pass_in_trip pit, trip t
 where p.id_psg = pit.id_psg
   and pit.trip_no = t.trip_no
   and p.id_psg not in (
                    --пассажиры летавшие на одинаковых местах
                    select id_psg
                      from --группировка по пассажирам и местам
                            (select p.id_psg, p.name, pit.place, count(*)
                               from Passenger p, Pass_in_trip pit
                              where p.id_psg = pit.id_psg
                              group by p.id_psg, p.name, pit.place
                             --order by p.id_psg, p.name, pit.place
                             having count(*) > 1))
 )
 group by id_psg 
 ) g
 where p1.id_psg=g.id_psg


/*
name  minutes
Alan Rickman  115
George Clooney  650
Harrison Ford 1800
Jennifer Lopez  332
Kevin Costner 788
Kurt Russell  1797
Michael Caine 2100
Ray Liotta  789
Russell Crowe 840
Steve Martin  1440
*/


Задание: 72 (Serge I: 2003-04-29)

Среди тех, кто пользуется услугами только какой-нибудь одной компании, определить имена разных пассажиров, летавших чаще других.
Вывести: имя пассажира и число полетов.

with pt as
(
select id_psg, count(*) cnt 
--Пассажиры и число их полетов
  from Pass_in_trip 
 where id_psg in (
                  --Пассажиры пользующиеся услугами только какой-нибудь одной компании
                  select id_psg /*, count(*)*/
                    from (
                           --Группировка пассажиров и исп.компаний по рейсам
                           select pit.id_psg, c.id_comp
                             from Pass_in_trip pit, trip t, company c
                            where pit.trip_no = t.trip_no
                              and t.id_comp = c.id_comp
                            group by pit.id_psg, c.id_comp)
                   group by id_psg
                  having count(*) = 1)
group by id_psg
) 
select p.name, pt.cnt from pt, Passenger p
 where pt.id_psg=p.id_psg 
 and cnt=(select max(cnt) from pt)

 


--Группировка пассажиров и исп.компаний по рейсам
select pit.id_psg, c.id_comp, count(*)
  from Pass_in_trip pit, trip t, company c
 where pit.trip_no = t.trip_no
   and t.id_comp = c.id_comp
 group by pit.id_psg, c.id_comp
 having 
-- order by pit.id_psg, c.id_comp


Задание: 68 (Serge I: 2010-03-27)

Найти количество маршрутов, которые обслуживаются наибольшим числом рейсов.
Замечания.
1) A - B и B - A считать ОДНИМ И ТЕМ ЖЕ маршрутом.
2) Использовать только таблицу Trip


select count(*) QTY
  from (
        --Количество рейсов по маршрутам
        SELECT town_from c1, town_to c2, count(*) cnt
          from trip
         where town_from >= town_to
         group by town_from, town_to
        union all
        SELECT town_to, town_from, count(*) cnt
          from trip
         where town_to > town_from
         group by town_from, town_to) t_m
 where t_m.cnt = (
                  --максимальное количество рейсов на маршрут
                  select max(cnt) max_trip
                    from (SELECT town_from c1, town_to c2, count(*) cnt
                             from trip
                            where town_from >= town_to
                            group by town_from, town_to
                           union all
                           SELECT town_to, town_from, count(*) cnt
                             from trip
                            where town_to > town_from
                            group by town_from, town_to))


SELECT town_from c1, town_to c2, count(*) cnt from trip
where town_from>=town_to
group by town_from, town_to
union all
SELECT town_to, town_from, count(*) cnt from trip
where town_to>town_from
group by town_from, town_to


--where trim(tr1.town_from)='Rostov' and trim(tr1.town_to)='Moscow' 
--or trim(tr1.town_to)='Rostov' and trim(tr1.town_from)='Moscow' 

select count(*) QTY from
(
--Количество рейсов по маршрутам
select tr.town_from, tr.town_to, count(*) cnt
from trip tr
group by tr.town_from, tr.town_to
) t_m where t_m.cnt=
(
--максимальное количество рейсов на маршрут
select max(cnt) max_trip from
(
select tr.town_from, tr.town_to, count(*) cnt
from trip tr
group by tr.town_from, tr.town_to
)
)

Задание: 67 (Serge I: 2010-03-27)

Найти количество маршрутов, которые обслуживаются наибольшим числом рейсов.
Замечания.
1) A - B и B - A считать РАЗНЫМИ маршрутами.
2) Использовать только таблицу Trip

select count(*) QTY from
(
--Количество рейсов по маршрутам
select tr.town_from, tr.town_to, count(*) cnt
from trip tr
group by tr.town_from, tr.town_to
) t_m where t_m.cnt=
(
--максимальное количество рейсов на маршрут
select max(cnt) max_trip from
(
select tr.town_from, tr.town_to, count(*) cnt
from trip tr
group by tr.town_from, tr.town_to
)
)

Задание: 66 (Serge I: 2003-04-09)

Для всех дней в интервале с 01/04/2003 по 07/04/2003 определить число рейсов из Rostov.
Вывод: дата, количество рейсов

select dt, sum(qty) qty
  from (select to_date('01/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select to_date('02/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select to_date('03/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select to_date('04/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select to_date('05/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select to_date('06/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select to_date('07/04/2003', 'dd/mm/yyyy') dt, 0 as qty
          from dual
        union all
        select "date" dt, count(*) as qty
          from (select *
                  from (
                        --рейсы по дням
                        select pit.trip_no, pit."date"
                          from Pass_in_trip pit
                         group by pit.trip_no, pit."date") td,
                       trip tr
                 where td.trip_no = tr.trip_no
                   and tr.town_from = 'Rostov'
                   and td."date" >= to_date('01/04/2003', 'dd/mm/yyyy')
                   and td."date" <= to_date('07/04/2003', 'dd/mm/yyyy')
                --order by td."date"
                )
         group by "date")
 group by dt
 order by dt



Задание: 63 (Serge I: 2003-04-08)

Определить имена разных пассажиров, когда-либо летевших на одном и том же месте более одного раза.

select name
  from passenger p
 where p.id_psg in (select --pt.place, 
                           pss.id_psg--, 
                           --pss.name, 
                           --count(*) cnt
                      from Passenger pss, 
                           Pass_in_trip pt
                     where pss.id_psg = pt.id_psg
                     group by pt.place, pss.id_psg--, pss.name
                    having count(*) > 1)


select name
  from  (select pt.place, 
                           pss.id_psg, 
                           pss.name, 
                           count(*) cnt
                      from Passenger pss, 
                           Pass_in_trip pt
                     where pss.id_psg = pt.id_psg
                     group by pt.place, pss.id_psg, pss.name
                    having count(*) > 1)


select * from Passenger  
select * from Pass_in_trip
group by name
having count(*)>1






Краткая информация о базе данных "Окраска"

Схема базы данных состоит из трех отношений:
utQ (Q_ID int, Q_NAME varchar(35)); 

select * from utQ 

Q_ID  Q_NAME
1 Square # 01
2 Square # 02
...............
23  Square # 23
25  Square # 25

utV (V_ID int, V_NAME varchar(35), V_COLOR char(1)); 

select * from utV

V_ID  V_NAME  V_COLOR
1 Balloon # 01  R
2 Balloon # 02  R
3 Balloon # 03  R
4 Balloon # 04  G
5 Balloon # 05  G
...........................
53  Balloon # 53  G
54  Balloon # 54  B


utB (B_Q_ID int, B_V_ID int, B_VOL tinyint, B_DATETIME datetime).

select * from utB

B_DATETIME  B_Q_ID  B_V_ID  B_VOL
01.01.03 01:12:01,000000  1 1 155
23.06.03 01:12:02,000000  1 1 100
.......................................
01.01.02 01:13:38,000000  22  51  50
01.06.02 01:13:39,000000  22  51  50
01.01.03 01:13:05,000000  4 37  185


Таблица utQ содержит идентификатор и название квадрата, цвет которого первоначально черный.
Таблица utV содержит идентификатор, название и цвет баллончика с краской.
Таблица utB содержит информацию об окраске квадрата баллончиком: идентификатор квадрата, идентификатор баллончика, 
количество краски и время окраски.
При этом следует иметь в виду, что:
- баллончики с краской могут быть трех цветов - красный V_COLOR='R', зеленый V_COLOR='G', голубой V_COLOR='B' (латинские буквы).
- объем баллончика равен 255 и первоначально он полный;
- цвет квадрата определяется по правилу RGB, т.е. R=0,G=0,B=0 - черный, R=255, G=255, B=255 - белый;
- запись в таблице закрасок utB уменьшает количество краски в баллончике на величину B_VOL и соответственно увеличивает 
количество краски в квадрате на эту же величину;
- значение 0 < B_VOL <= 255;
- количество краски одного цвета в квадрате не превышает 255, а количество краски в баллончике не может быть меньше нуля;
- время окраски B_DATETIME дано с точностью до секунды, т.е. не содержит миллисекунд.



Задание: 138 (Serge I: 2017-03-10)

Найти все уникальные пары нечёрных квадратов (q_id1 и q_id2), 
которые окрашивались одним и тем же множеством баллончиков.
Вывод: q_id1, q_id2, где q_id1 < q_id2.

select * from utQ
select * from utV
select * from utB

/* 
Q1  Q2
11  12
17  19
18  20
*/

Задание: 135 (Serge I: 2016-12-16)

В пределах каждого часа, в течение которого выполнялись окраски, 
найти максимальное время окраски (B_DATETIME).


select distinct max_date_by_hour from 
(
select b_Datetime, 
       max(b_Datetime) over(partition by to_char(b_Datetime, 'dd.mm.yyyy hh24')) max_date_by_hour
  from utB
) order by max_date_by_hour


select distinct max_date_by_hour from 
(
select b_Datetime, 
       hours,
       max(b_Datetime) over(partition by hours) max_date_by_hour
  from (select b_Datetime, to_char(b_Datetime, 'dd.mm.yyyy hh24') hours
          from utB)
) order by max_date_by_hour

/*
MAX_TIME
2000-01-01 01:13:36
2001-01-01 01:13:37
2002-01-01 01:13:38
2002-06-01 01:13:39
2003-01-01 01:13:26
2003-02-01 01:13:31
2003-02-02 01:13:32
2003-02-03 01:13:33
2003-02-04 01:13:34
2003-02-05 01:13:35
2003-03-01 01:13:28
2003-04-01 01:13:29
2003-05-01 01:13:30
2003-06-11 01:13:23
2003-06-23 01:12:02
*/


Задание: 129 (Serge I: 2008-02-01)

Предполагая, что среди идентификаторов квадратов имеются пропуски, 
найти минимальный и максимальный "свободный" идентификатор в диапазоне 
между имеющимися максимальным и минимальным идентификаторами. 
Например, для последовательности идентификаторов квадратов 1,2,5,7 результат должен быть 3 и 6.
Если пропусков нет, вместо каждого искомого значения выводить NULL.

Подcказки к задаче №129
Номера идентификаторов могут быть отрицательными.

select min(q), max(q) from
(
select q_id + 1 as q
  from (select q_id, lead(q_id) over(order by q_id) nxt from utQ)
 where (q_id + 1 <> nxt)
union
select q_id - 1 as q
  from (select q_id, lag(q_id) over(order by q_id) prev from utQ)
 where (q_id - 1 <> prev)
)

select q_id+1, nxt, prev, maxi, mini from 
(
select q_id,
       lead(q_id) over(order by q_id) nxt,
       lag(q_id) over(order by q_id) prev,
       max(q_id) over() maxi,
       min(q_id) over() mini
from utQ
) where ( q_id + 1 <> nxt) /*and (q_id - 1 <> prev) and (q_id <> maxi) and (q_id <> mini)*/

select min(gen.id_all) q_min, max(gen.id_all) q_max from
(
select rownum id_all
  from dual
connect by rownum >= (select min(q_Id) from utQ)
       and (rownum <= (select max(q_Id) from utQ))) gen, utQ       
where gen.id_all = utQ.q_Id(+)       
and utQ.q_Name is null 

/*
Q_MIN	Q_MAX
24	24
*/

Задание: 119 ($erges: 2008-04-25)

Сгруппировать все окраски по дням, месяцам и годам. Идентификатор 
каждой группы должен иметь вид "yyyy" для года, "yyyy-mm" для месяца и "yyyy-mm-dd" для дня.
Вывести только те группы, в которых количество различных моментов 
времени (b_datetime), когда выполнялась окраска, более 10.
Вывод: идентификатор группы, суммарное количество потраченной краски.

Подcказки к задаче №119

Нужно подсчитывать моменты времени, а не факты окраски, 
т.к. в один момент времени может быть несколько окрасок.
Ошибка приводит к тому, что учитываются группы, 
в которых имеется более 10 окрасок, хотя при этом различных моментов времени менее 10.


with tmp as
(
select b_Datetime, sum(b_vol) b_vol from utB group by b_Datetime
)
select to_char(b_Datetime,'yyyy') period, sum(b_vol) vol 
from tmp
group by to_char(b_Datetime,'yyyy')
having count(*)>10
union all
select to_char(b_Datetime,'yyyy-mm') period, sum(b_vol) vol 
from tmp
group by to_char(b_Datetime,'yyyy-mm')
having count(*)>10
union all
select to_char(b_Datetime,'yyyy-mm-dd') period, sum(b_vol) vol 
from tmp
group by to_char(b_Datetime,'yyyy-mm-dd')
having count(*)>10

/*
period	vol
2003-01-01	8679
2003-01	8679
2003	9070
*/






Задание: 116 (Velmont: 2013-11-19)

Считая, что каждая окраска длится ровно секунду, определить непрерывные интервалы времени 
с длительностью более 1 секунды из таблицы utB.
Вывод: дата первой окраски в интервале, дата последней окраски в интервале.

--MS SQL
select min(B_DATETIME) be, max(B_DATETIME) fin from
(
  select B_DATETIME, dateadd(ss, -row_number() over(order by B_DATETIME), B_DATETIME) num from
  ( 
    select distinct B_DATETIME from utB
  ) x
) y
group by num
having count(*) > 1



with tmp1 as 
(
select b_Datetime, prev, nxt
from
(
select b_Datetime, 
       nvl(LAG(b_Datetime) over (order by b_Datetime),to_date('01.01.1900','dd.mm.yyyy')) prev, 
       nvl(LEAD(b_Datetime) over (order by b_Datetime), to_date('01.01.4000','dd.mm.yyyy')) nxt 
from (select distinct b_Datetime from utB)
) where cast(b_Datetime as date) = cast(prev as date) + 1/24/60/60 --Выводим граничные даты +- 1сек
  or cast(b_Datetime as date) = cast(nxt as date) - 1/24/60/60
),
tmp2 as
(
select b_Datetime,
       ROW_NUMBER() over (order by b_Datetime) rn,
       nvl(LAG(b_Datetime) over (order by b_Datetime),to_date('01.01.1900','dd.mm.yyyy')) prev, 
       nvl(LEAD(b_Datetime) over (order by b_Datetime), to_date('01.01.4000','dd.mm.yyyy')) nxt 
 from tmp1
where cast(b_Datetime as date) > cast(prev as date) + 1/24/60/60 --Выводим граничные даты интервалов
or cast(b_Datetime as date) < cast(nxt as date) - 1/24/60/60 
order by b_Datetime
) select b_Datetime DATE_BEGIN, nxt DATE_FINISH
 from tmp2
 where mod(rn,2)<>0



/*
B_DATETIME  PREV  NXT
01.01.03 01:12:03,000000  01.01.03 01:12:01,000000  01.01.03 01:12:04,000000
01.01.03 01:12:33,000000  01.01.03 01:12:31,000000  01.01.03 01:12:34,000000
01.01.03 01:12:48,000000  01.01.03 01:12:47,000000  01.01.03 01:13:01,000000
01.01.03 01:13:01,000000  01.01.03 01:12:48,000000  01.01.03 01:13:02,000000
01.01.03 01:13:18,000000  01.01.03 01:13:17,000000  01.01.03 01:13:24,000000
01.01.03 01:13:24,000000  01.01.03 01:13:18,000000  01.01.03 01:13:25,000000
01.01.03 01:13:26,000000  01.01.03 01:13:25,000000  01.02.03 01:13:19,000000
*/

/*
DATE_BEGIN	DATE_FINISH
2003-01-01 01:12:03	2003-01-01 01:12:31
2003-01-01 01:12:33	2003-01-01 01:12:48
2003-01-01 01:13:01	2003-01-01 01:13:18
2003-01-01 01:13:24	2003-01-01 01:13:26
*/


Задание: 115 (Baser: 2013-11-01)

Рассмотрим равнобочные трапеции, в каждую из которых можно вписать касающуюся всех сторон окружность. 
Кроме того, каждая сторона имеет целочисленную длину из множества значений b_vol.
Вывести результат в 4 колонки: Up, Down, Side, Rad. Здесь Up - меньшее основание, 
Down - большее основание, Side - длины боковых сторон, Rad – радиус вписанной окружности (с 2-мя знаками после запятой).

select distinct b1.b_vol Up, b2.b_vol Down, b3.b_vol Side, 
       round(0.25 * sqrt(4*b3.b_vol*b3.b_vol - (b2.b_vol-b1.b_vol)*(b2.b_vol-b1.b_vol)),2) Rad  --Радиус впис.окрудности равен половине высоты
       from utB b1, utB b2, utB b3
where b1.b_vol < b2.b_vol --Up - меньшее основание меньше большего основания Down
and b3.b_vol < b2.b_vol -- Side длина боковой стороны меньше основания Down
and b3.b_vol = (b1.b_vol + b2.b_vol)/2 --Если в равноб.трапецию можно вписать окружность, то боковая сторона равна средней лини трапеции
and 4*b3.b_vol*b3.b_vol - (b2.b_vol-b1.b_vol)*(b2.b_vol-b1.b_vol) > 0 --Квадратный корень из этого числа  д.б. > 0


/*
UP	DOWN	SIDE	RAD
155	255	205	99.4
1	245	123	7.83
*/


Задание: 113 (Serge I: 2003-12-24)

Сколько каждой краски понадобится, чтобы докрасить 
все Не белые квадраты до белого цвета.
Вывод: количество каждой краски в порядке (R,G,B)


select sum(r), sum(g), sum(b) from 
(
select          
       b_q_id,
       255 - count_color_red r,
       255 - count_color_green g,
       255 - count_color_blue b      
from 
(       
--Сколько и какой краски израсходовано по квадратам
select utB.b_q_id,
        sum(case when utV.v_color = 'R' then utB.b_vol else 0  end) count_color_red,
        sum(case when utV.v_color = 'G' then utB.b_vol else 0  end) count_color_green,
        sum(case when utV.v_color = 'B' then utB.b_vol else 0  end) count_color_blue
  from utV, utB
 where 1 = 1
   and utB.b_v_id = utV.v_id
 group by utB.b_q_id 
 --Не белые и не черные квадраты
 having sum(utB.b_vol)<765
union  
--Черные квадраты 
select  utQ.q_Id, 
        0 count_color_red,
        0 count_color_green,
        0 count_color_blue
  from  utQ, utB
where utQ.q_Id=utB.b_q_Id(+)
and utB.b_Vol is null
) 
)
         


/*
RED	GREEN	BLUE
2975	3069	3046
*/


Задание: 112 (Serge I: 2003-12-24)

Какое максимальное количество черных квадратов можно было бы окрасить в белый цвет
оставшейся краской


select case
         when count(*) = 3 then
          trunc(min(cnt_color))
         else
          0
       end as qty
  from (select v_Color, sum(Remain) / 255 cnt_color
          from (
                --Осталось краски по балончикам
                select utV.v_Id,
                        utV.v_Color,
                        case
                          when sum(utB.b_vol) is null then
                           255
                          else
                           255 - sum(utB.b_vol)
                        end Remain
                  from utB, utV
                 where 1 = 1
                   and utV.v_id = utB.b_v_id(+)
                 group by utV.v_Id, utV.v_Color)
         group by v_Color)



select case
         when count(*) = 3 then
          trunc(min(cnt))
         else
          0
       end as qty
  from (select ((count(distinct utV.V_ID) * 255 - sum(utB.B_VOL)) / 255) as cnt
          from utv
          left join utB
            on utB.B_V_ID = utV.V_ID
         group by utV.V_COLOR)


select nvl(cnt_wt,0) from 
(
select min(cnt_color) cnt_wt, count(*) cnt from 
(
select v_Color, sum(Remain)/255 cnt_color from 
(
--Осталось краски по балончикам
select utV.v_Id, utV.v_Color,
       case when sum(utB.b_vol) is null then 255 else 255-sum(utB.b_vol) end Remain
  from utB, utV
 where 1 = 1
   and utV.v_id = utB.b_v_id(+)
 group by utV.v_Id, utV.v_Color
) group by v_Color 
)
) where cnt=3


/*
QTY
4
*/



Задание: 111 (Serge I: 2003-12-24)

Найти НЕ белые и НЕ черные квадраты, которые окрашены разными цветами в пропорции 1:1:1. 
Вывод: имя квадрата, количество краски одного цвета


select utQ.q_Name, Sq111.count_color_red cnt
  from (
        --Сколько и какой краски израсходовано по квадратам
        select utB.b_q_id,
                sum(case when utV.v_color = 'R' then utB.b_vol else 0  end) count_color_red,
                sum(case when utV.v_color = 'G' then utB.b_vol else 0  end) count_color_green,
                sum(case when utV.v_color = 'B' then utB.b_vol else 0  end) count_color_blue
          from utB, utV
         where 1 = 1
           and utB.b_v_id = utV.v_id
         group by utB.b_q_id 
         --Не белые и не черные квадраты
         having sum(utB.b_vol)<765) Sq111, utQ   
 where Sq111.b_q_id = utQ.q_Id
   --квадраты, которые окрашены разными цветами в пропорции 1:1:1
   and count_color_red = count_color_green 
   and count_color_green = count_color_blue 




select Sq.q_Name, Sq111.count_color_red cnt
  from (
        --Сколько и какой краски израсходовано по квадратам
        select clr.b_q_id,
                sum(case when v_color = 'R' then b_vol else 0  end) count_color_red,
                sum(case when v_color = 'G' then b_vol else 0  end) count_color_green,
                sum(case when v_color = 'B' then b_vol else 0  end) count_color_blue
          from utB clr, utV bal
         where 1 = 1
           and clr.b_v_id = bal.v_id
         group by clr.b_q_id) Sq111, utQ Sq   
 where Sq111.b_q_id = Sq.q_Id
   --квадраты, которые окрашены разными цветами в пропорции 1:1:1
   and count_color_red = count_color_green 
   and count_color_green = count_color_blue 
and Sq.q_Name not in
(
select q_name
--Белые и черные квадраты
from utQ u left join 
(select b_q_id, sum(b_vol) color from uTb
group by b_q_id) c 
on u.Q_ID = c.B_Q_ID 
where c.B_Q_ID is null or c.color = 765
)

Q_NAME  QTY


with cte as
(
   select b_q_id, sum(b_vol) color from uTb
	group by b_q_id
) 
select *-- q_name
from utQ u left join cte c on u.Q_ID = c.B_Q_ID 
    where c.B_Q_ID is null or c.color = 765



Задание: 109 (qwrqwr: 2011-01-13)

Вывести:
1. Названия всех квадратов черного или белого цвета.
2. Общее количество белых квадратов.
3. Общее количество черных квадратов.


with Wts as 
(
select Sq.q_Name
--Квадраты покрашенные в белый цвет (R=255, G=255, B=255):
  from (
        --Сколько и какой краски израсходовано по квадратам
        select clr.b_q_id,
                sum(case
                      when v_color = 'R' then
                       b_vol
                      else
                       0
                    end) count_color_red,
                sum(case
                      when v_color = 'G' then
                       b_vol
                      else
                       0
                    end) count_color_green,
                sum(case
                      when v_color = 'B' then
                       b_vol
                      else
                       0
                    end) count_color_blue
          from utB clr, utV bal
         where 1 = 1
           and clr.b_v_id = bal.v_id
         group by clr.b_q_id) SqWhite, utQ Sq   
 where SqWhite.b_q_id = Sq.q_Id
   and count_color_red = 255
   and count_color_green = 255
   and count_color_blue = 255
),
Bls as 
(
select utQ.q_Name from utQ, utB
where utQ.q_id = utB.b_q_Id(+) 
and utB.b_vol is null
)
select q_Name, (select count(*) from  Wts) as whites, (select count(*) from  Bls) as blacks
from 
(
select q_Name from Wts
union
select q_Name from Bls
)

with cte as
(
   select b_q_id, sum(b_vol) color from uTb
	group by b_q_id
) 
select q_name,
    sum(case when color = 765 then 1 else 0 end) over() w,
    sum(case when color is null then 1 else 0 end) over() b
from utQ u left join cte c on u.Q_ID = c.B_Q_ID 
    where c.B_Q_ID is null or c.color = 765


select
	min(q_name) as name,
	count(all min(b_q_id)) over () as whites,
	count(*) over () - count(all min(b_q_id)) over () as blacks
from utq
left join utb
	on b_q_id = q_id
group by q_id
having min(b_q_id) is null or sum(b_vol) = 765


Задание: 108 (Baser: 2013-10-16)

Реставрация экспонатов секции "Треугольники" музея ПФАН проводилась согласно техническому заданию.
Для каждой записи таблицы utb малярами подкрашивалась сторона любой фигуры, если длина этой стороны равнялась b_vol.
Найти окрашенные со всех сторон треугольники, кроме равносторонних, равнобедренных и тупоугольных.
Для каждого треугольника (но без повторений) вывести три значения X, Y, Z, где X - меньшая, Y - средняя, а Z - большая сторона.


select distinct b1.b_vol A, b2.b_vol B, b3.b_vol C
  from utb b1, utb b2, utb b3
 where b1.b_vol < b2.b_vol
   and b2.b_vol < b3.b_vol
   and not (b3.b_vol > sqrt(b1.b_vol*b1.b_vol + b2.b_vol*b2.b_vol))

select * from utB

/*
a b c
100 111 123
100 123 155
100 185 205
100 245 255
111 123 155
111 155 185
111 185 205
111 245 255
123 155 185
123 185 205
123 245 255
155 185 205
155 205 245
155 205 255
155 245 255
185 205 245
185 205 255
185 245 255
205 245 255
50  100 111
*/



Задание: 106 (Baser: 2013-09-06)

Пусть v1, v2, v3, v4, ... представляет последовательность вещественных чисел - объемов окрасок b_vol, 
упорядоченных по возрастанию b_datetime, b_q_id, b_v_id.
Найти преобразованную последовательность P1=v1, P2=v1/v2, P3=v1/v2*v3, P4=v1/v2*v3/v4, ..., 
где каждый следующий член получается из предыдущего умножением на vi (при нечетных i) или делением на vi (при четных i).
Результаты представить в виде b_datetime, b_q_id, b_v_id, b_vol, Pi, где Pi - член последовательности, 
соответствующий номеру записи i. Вывести Pi с 8-ю знаками после запятой.

WITH seq AS
 (SELECT b_datetime,
         b_q_id,
         b_v_id,
         b_vol,
         ROW_NUMBER() OVER(ORDER BY b_datetime, b_q_id, b_v_id) i
    FROM utb),
req(i,
p) AS
 (SELECT i i, b_vol p
    FROM seq
   WHERE i = 1
  UNION ALL
  SELECT req.i + 1, p * power(seq.b_vol, power(-1, req.i)) p
    FROM req, seq
   WHERE seq.i = req.i + 1
     AND req.i + 1 <= (SELECT MAX(i) FROM seq))
SELECT b_datetime, b_q_id, b_v_id, b_vol, round(p, 8) p
  FROM req, seq
 WHERE req.i = seq.i;

WITH utBBB AS
 (SELECT b_datetime,
         b_q_id,
         b_v_id,
         B_VOL,
         ROW_NUMBER() OVER(ORDER BY b_datetime, b_q_id, b_v_id) n
    FROM utB)
SELECT b_datetime,
       b_q_id,
       b_v_id,
       B_VOL,
       round(exp(sum(ln(case
                when mod(n, 2) = 0 then
                 1.0 / cast(B_VOL as number(18, 8))
                else
                 B_VOL
              end)) OVER(ORDER BY b_datetime, b_q_id, b_v_id)),8) X
  FROM utBBB



WITH utBBB AS
 (SELECT b_datetime,
         b_q_id,
         b_v_id,
         B_VOL,
         ROW_NUMBER() OVER(ORDER BY b_datetime, b_q_id, b_v_id) n
    FROM utB)
SELECT b_datetime,
       b_q_id,
       b_v_id,
       B_VOL,
       sum(B_VOL) OVER(ORDER BY b_datetime, b_q_id, b_v_id) X
  FROM utBBB


50
50/50
50/50*50
50/50*50/50
50/50*50/50*155/255

select b_Datetime,
       b_q_Id,
       b_v_Id,
       b_Vol,
       rn,
       prev,
       nxt,
       case when rn = 1 then b_vol 
            when (rn > 1) and  (mod(rn,2)=1) then b_vol*nvl(nxt,1) 
            when (rn > 1) and  (mod(rn,2)=0) then b_vol/nvl(nxt,1) 
            end Pi    
       from       
(
select utB.b_Datetime,
       utB.b_q_Id,
       utB.b_v_Id,
       utB.b_Vol,
       row_number() over (order by b_datetime, b_q_id, b_v_id) as rn,
       LAG(utB.b_Vol) over (order by b_datetime, b_q_id, b_v_id) as prev,
       LEAD(utB.b_Vol) over (order by b_datetime, b_q_id, b_v_id) as nxt
        from utB
)        
order by rn

/*
B_DATETIME  B_Q_ID  B_V_ID  B_VOL V
2000-01-01 01:13:36 22  50  50  50
2001-01-01 01:13:37 22  50  50  1
2002-01-01 01:13:38 22  51  50  50
2002-06-01 01:13:39 22  51  50  1
2003-01-01 01:12:01 1 1 155 155
2003-01-01 01:12:03 2 2 255 .60784314
2003-01-01 01:12:04 3 3 255 155
2003-01-01 01:12:05 1 4 255 .60784314
.................................
*/

Задание: 96 (ZrenBy: 2003-09-01)

При условии, что баллончики с красной краской использовались более одного раза, 
выбрать из них такие, которыми окрашены квадраты, имеющие голубую компоненту.
Вывести название баллончика

with v_r as
(
--баллончики с красной краской использованные более одного раза
select utV.v_Id
 from utV, utB
where utV.v_Id = utB.b_v_Id
  and utV.v_Color = 'R'
group by utV.v_Id
having count(*) > 1
) 
select distinct V1.V_NAME from v_r, utB B1, utV V1
  where v_r.v_Id = B1.b_v_Id
  and v_r.v_Id = v1.v_Id 
   and exists (--квадраты, имеющие голубую компоненту
               select 1
               from utV V2, utB B2
               where V2.v_Id = B2.b_v_Id
               and V2.v_Color = 'B'  
               and B2.B_Q_ID=B1.B_Q_ID)




--баллончики с красной краской использованные более одного раза
select utV.v_Id, count(*) cnt_used from utV, utB
where utV.v_Id = utB.b_v_Id
      and utV.v_Color='R'
group by utV.v_Id    
having count(*)>1  


select utQ.q_Name from utQ
where utQ.q_Id in
(
--квадраты, имеющие голубую компоненту
select distinct B1.b_q_Id
  from utV V1, utB B1
 where V1.v_Id = B1.b_v_Id
   and V1.v_Color = 'B'
   and exists (select 1
          from utB B2
         where B2.B_Q_ID = B1.B_Q_ID
           and B2.B_V_ID in (
                             --баллончики с красной краской использованные более одного раза
                             select utV.v_Id
                               from utV, utB
                              where utV.v_Id = utB.b_v_Id
                                and utV.v_Color = 'R'
                              group by utV.v_Id
                             having count(*) > 1))
)

Задание: 92 (ZrenBy: 2003-09-01)

Выбрать все белые квадраты, которые окрашивались только из баллончиков,
пустых к настоящему времени. Вывести имя квадрата



select Sq.q_Name
--Квадраты покрашенные в белый цвет (R=255, G=255, B=255):
  from (
        --Сколько и какой краски израсходовано по квадратам
        select clr.b_q_id,
                sum(case
                      when v_color = 'R' then
                       b_vol
                      else
                       0
                    end) count_color_red,
                sum(case
                      when v_color = 'G' then
                       b_vol
                      else
                       0
                    end) count_color_green,
                sum(case
                      when v_color = 'B' then
                       b_vol
                      else
                       0
                    end) count_color_blue
          from utB clr, utV bal
         where 1 = 1
           and clr.b_v_id = bal.v_id
              --Cмотрим только среди балончиков, пустых к настоящему времени
           and bal.v_id in (select v_id
                              from (select bal1.v_id,
                                           bal1.v_color,
                                           sum(clr1.b_vol) sum_b_vol
                                      from utB clr1, utV bal1
                                     where 1 = 1
                                       and clr1.b_v_id = bal1.v_id
                                     group by bal1.v_id, bal1.v_color)
                             where 1 = 1
                               and sum_b_vol = 255)
         group by clr.b_q_id) SqWhite, utQ Sq   
 where SqWhite.b_q_id = Sq.q_Id
   and count_color_red = 255
   and count_color_green = 255
   and count_color_blue = 255


/*
Q_NAME
Square # 01
Square # 02
Square # 03
Square # 06
Square # 09
Square # 11
Square # 12
*/


Задание: 91 (Serge I: 2015-03-20)

C точностью до двух десятичных знаков определить среднее количество краски на квадрате.

(
Подcказки к задаче №91
Учтите черные квадраты и вариант, когда окрасок нет вообще (т.е. все квадраты черные).
)

select * from utQ 
select * from utV
select * from utB

select CAST(avg(sum_By_q_Id) as number(6, 2)) as avg_
  from (select nvl(sum(b_vol),0) sum_By_q_Id from utq
          left join utb
            on utq.q_id = utb.b_q_id
         group by q_id) x

select round(avg(sum_By_q_Id),2) as avg_
  from (select nvl(sum(b_vol),0) sum_By_q_Id from utq
          left join utb
            on utq.q_id = utb.b_q_id
         group by q_id) x


select CAST(avg(sum_By_q_Id) as number(6, 2)) as avg_
  from (select case
                 when sum(b_vol) IS NULL THEN
                  0
                 ELSE
                  CAST(sum(b_vol) AS number(6, 2))
               END sum_By_q_Id
          from utq
          left join utb
            on utq.q_id = utb.b_q_id
         group by q_id) x



--Сколько и какой краски израсходовано всего
select sum(count_color_red),
       sum(count_color_green),
       sum(count_color_blue),
       sum(count_color_RGB), 
       sum(count_color_RGB)--/(select count(1) from utQ) as count_color_avgSq
       from
(
--Сколько и какой краски израсходовано по квадратам
select clr.b_q_id,
        sum(case
              when v_color = 'R' then
               b_vol
              else
               0
            end) count_color_red,
        sum(case
              when v_color = 'G' then
               b_vol
              else
               0
            end) count_color_green,
        sum(case
              when v_color = 'B' then
               b_vol
              else
               0
            end) count_color_blue,
        sum(b_vol) count_color_RGB 
   from utB clr, utV bal
 where 1 = 1
   and clr.b_v_id = bal.v_id
 group by clr.b_q_id
)


/*
select * from utB
where utB.b_q_Id=2
order by utb.b_datetime, utB.b_q_Id, utB.b_v_Id



select round(avg(sum1),2) avg1 from
(
select utB.b_q_Id, sum(utB.b_Vol) sum1, avg(sum(utB.b_Vol)) over() avg_q   from utB
--where utB.b_q_Id=2
group by utB.b_q_Id
)
*/
/*
AVG_QTY
386.25
*/

