DECLARE     @return_value int
EXEC  @return_value = [dbo].[PES_SP_CALL_SSIS_FLAT_RAW_PACKAGE]
            @BOLFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_BOL.txt',
            @CmdFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_Commodity.txt',
            @CntrFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_Container.txt',
            @ConsFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_Consignee.txt',
            @HazmFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_HAZMAT.txt',
            @MANFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_MANandNBRS.txt',
            @AlsoNtfFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_AlsoNotify.txt',
            @NtfFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_Notify.txt',
            @ShpFile = N'E:\PIERS Enterprise Solution\Output\SSISFiles\FEED_IBI\20121108_234320\20121108_234320_Shipper.txt',
            @SrcFileName = N'AMS121024_2.zip'

SELECT      'Return Value' = @return_value

