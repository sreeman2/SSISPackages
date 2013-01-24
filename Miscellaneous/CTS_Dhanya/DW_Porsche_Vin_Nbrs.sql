-- DW 
SELECT * INTO WORKTEMP.DBO.PORSCHE_VINS_DW
  FROM PESDW.DBO.PES_DW_VIN (NOLOCK)
WHERE BILL_NUMBER IN 
(
'GZ07BABR0004',
'AS059NGO5047',
'AS059YOK5050',
'MM002YOK5062',
'PHX219233700',
'GZ07BALH0007',
'MSCUMC990423',
'6062747059',
'NWGJ2697074',
'NWGJ2697074',
'MSCUAR012152',
'S306429776',
'S306379947',
'PHX223061100',
'MIA051919',
'MSCUMC967421',
'S306376038') 
AND VIN_NUMBER IN
(
'WP0AB0912GS120648',
'WP0AA2A76LB019954',
'WP1AD29P88LA72897',
'WP0AB29088S740081',
'WP1AA2A29CLA06230',
'WP0CB2981YU553268',
'4JGBB8G89BA673452',
'4JGBF2FE6CA795277',
'4JGDA5GBXCA064767',
'4JGDA5HB7CA075678',
'4JGQA5HB3CA072144',
'WDDGP8BB5BR149678',
'WDDGP8BB9BR141826',
'WDDHFBHB4BA349994',
'WDDL17DB6CA051277',
'WDDLJ98BXCA036392',
'WDDLJ9EB1CA037639'
)

BEGIN TRAN

UPDATE DWVIN SET VIN_NUMBER = PORSCHE.VIN_NUMBER,MODIFIED_DT = GETDATE(),MODIFIED_BY = USER
FROM PESDW.DBO.PES_DW_VIN DWVIN,[10.31.18.132].TEMP_PES.DBO.PORSCHE PORSCHE
WHERE DWVIN.BILL_NUMBER = PORSCHE.BOL_NBR
  AND DWVIN.VIN_NUMBER  = PORSCHE.WRONG_VIN_NBR

COMMIT TRAN

 