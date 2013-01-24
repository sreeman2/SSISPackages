select * --into worktemp.dbo.missing_ids 
from gtcore_masterdata.dbo.REF_VESSEL with (nolock)
where id in (
402736,
402834,
402784,
402832,
402778,
402797,
402839,
402780,
402837,
402790,
402840,
402776,
26093,
213,
402706,
402821,
402841,
402812,
402845,
402828,
402849,
402789,
402798,
10,
402846)

update ref set modified_dt = getdate()
from gtcore_masterdata.dbo.REF_VESSEL ref,worktemp.dbo.missing_ids ids
where ids.id = ref.id
