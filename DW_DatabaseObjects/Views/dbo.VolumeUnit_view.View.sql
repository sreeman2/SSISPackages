/****** Object:  View [dbo].[VolumeUnit_view]    Script Date: 01/08/2013 15:00:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[VolumeUnit_view] as 
select
	 cast(a.[ID] as int)	[VolumeUnit_Id]
	,a.[MEAS_UNIT]		[Code]
	,a.[DESCRIPTION]	[Description]
	,update_dt
from PES_RAW.pes.dbo.vREF_MEAS_UNIT a WITH (NOLOCK)
GO
