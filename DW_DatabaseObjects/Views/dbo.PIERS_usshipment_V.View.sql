/****** Object:  View [dbo].[PIERS_usshipment_V]    Script Date: 01/08/2013 15:00:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [aa] - 09/02/2010
-- Used to fetch updates to pre-PES data
-- JOINS usshipment & tnbr2recnum mapping
--  eliminates any recnums that we don't have t_nbr for (before 2006)
--  appends t_nbr for any recnums that we have t_nbr for (2006 onwards)
-- e.g. SELECT * FROM PESDW.dbo.PIERS_usshipment_V WHERE udate>=getdate()
CREATE VIEW [dbo].[PIERS_usshipment_V]
As
SELECT
tr.t_nbr,
--,u.*
-- [Shree / aa] - 11/12/2010 - expanded u.* to explicit column names
u.[bol_id],
u.[cmd_id],
u.[usshipment_id],
u.[vdate],
u.[dir],
u.[usport_id],
u.[fport_id],
u.[ultport_id],
u.[vessel_id],
u.[comcode],
u.[harm_code],
u.[comp_id],
u.[fcomp_id],
u.[ntfcomp_id],
u.[st],
u.[sline],
u.[ctrycode],
u.[qty],
u.[pounds],
u.[conflag],
u.[consize],
u.[conqty],
u.[convol],
u.[value],
u.[u_m],
u.[teu],
u.[bol_nbr],
u.[commodity],
u.[recnum],
u.[bank_id],
u.[is_valid],
u.[is_reefer],
u.[is_roro],
u.[nvocc_flag],
u.[is_financl],
u.[payable_flag],
u.[udate],
u.[usfinal],
u.[fgnfinal],
u.[usib_city],
u.[usib_st],
u.[org_dest_city],
u.[org_dest_st],
u.[manifest_nbr],
u.[voyage],
u.[pdate],
u.[com4],
u.[harm4],
u.[is_hazmat],
u.[fgnib_city],
u.[fgnib_ctry],
u.[conlength],
u.[conwidth],
u.[contype],
u.[fcharge],
u.[intransit_flag]
 FROM PESDW.dbo.PIERS_usshipment u
JOIN PESDW.dbo.PIERS_tnbr2recnum tr
 ON u.recnum = tr.recnum AND u.dir = tr.dir
WHERE u.is_valid = 'Y'
GO
