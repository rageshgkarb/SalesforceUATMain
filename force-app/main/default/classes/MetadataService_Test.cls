/*This is a dummy test class to obtain >75% coverage for the generated WSDL2Apex code in MetadataService, it is not a funcitonal test class
 **/ 
@isTest  
private class MetadataService_Test
{               
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {   
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new MetadataServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new MetadataServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new MetadataServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.readMetadata('Report',new String[]{'folder/report'});
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
    }
        
    @IsTest
    private static void coverGeneratedCodeTypes()
    {              
        // Reference types
        new MetadataService();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.checkDeployStatus_element();
        new MetadataService.CodeCoverageWarning();
        new MetadataService.DescribeMetadataResult();
        new MetadataService.DeployOptions();
        new MetadataService.PackageTypeMembers();
        new MetadataService.AsyncResult();
        new MetadataService.ProfileObjectPermissions();
        new MetadataService.ReportFilter();
        new MetadataService.ReportTypeColumn();
        new MetaDataService.PicklistEntry();
        new MetadataService.LogInfo();
        new MetaDataService.ValueTypeField();
        new MetadataService.DomainWhitelist();
        new MetadataService.CallOptions_element();
        new MetadataService.ReportBlockInfo();
        new MetadataService.describeMetadataResponse_element();
        new MetadataService.ObjectRelationship();
        new MetadataService.DeployMessage();
        new MetadataService.ReportColumn();
        new MetadataService.ReportType();
        new MetadataService.describeMetadata_element();
        new MetadataService.ReportParam();
        new MetadataService.RetrieveResult();
        new MetadataService.retrieve_element();
        new MetadataService.DescribeMetadataObject();
        new MetadataService.SharedTo();
        new MetadataService.ReportHistoricalSelector();
        new MetadataService.DeployDetails();
        new MetadataService.SessionSettings();
        new MetadataService.Package_x();
        new MetadataService.RunTestSuccess();
        new MetadataService.CodeCoverageResult();
        new MetadataService.deployResponse_element();
        new MetadataService.ReportAggregateReference();
        new MetadataService.RunTestFailure();
        new MetadataService.FileProperties();
        new MetadataService.ReportCrossFilter();
        new MetadataService.Report();
        new MetadataService.checkRetrieveStatus_element();
        new MetadataService.ReportFolder();
        new MetadataService.RetrieveRequest();
        new MetadataService.ListMetadataQuery();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.ReportBucketField();
        new MetadataService.ChartSummary();
        new MetadataService.ReportLayoutSection();
        new MetadataService.ReportTimeFrameFilter();
        new MetadataService.listMetadata_element();
        new MetadataService.MetadataWithContent();
        new MetadataService.Metadata();
        new MetadataService.ReportBucketFieldValue();
        new MetadataService.RetrieveMessage();
        new MetadataService.SessionHeader_element();
        new MetadataService.deploy_element();
        new MetadataService.retrieveResponse_element();
        new MetadataService.ReportGrouping();
        new MetadataService.ReportTypeColumnTranslation();
        new MetadataService.ReportChart();
        new MetadataService.checkRetrieveStatusResponse_element();
        new MetadataService.RunTestsResult();     
        new MetadataService.CodeLocation();
        new MetadataService.ReportBucketFieldSourceValue();
        new MetadataService.ReportFilterItem();
        new MetadataService.ReportAggregate();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.Folder();
        new MetadataService.DeployResult();
        new MetadataService.checkDeployStatusResponse_element();
        new MetadataService.ReportColorRange();
        new MetadataService.FolderShare();
        new MetadataService.renameMetadata_element();
        new MetadataService.deleteMetadataResponse_element();
        new MetadataService.Error();
        new MetadataService.SaveResult();
        new MetadataService.readMetadataResponse_element();
        new MetadataService.deleteMetadata_element();
        new MetadataService.createMetadataResponse_element();
        new MetadataService.updateMetadata_element();
        new MetadataService.updateMetadataResponse_element();
        new MetadataService.createMetadata_element();
        new MetadataService.readMetadata_element();
        new MetadataService.ReadReportTypeResult();
        new MetadataService.readReportTypeResponse_element();
        new MetadataService.ReadReportResult();
        new MetadataService.readReportResponse_element();
        new MetadataService.ReadFolderResult();
        new MetadataService.readFolderResponse_element();
        new MetadataService.ReadResult();
        new MetadataService.ReportDataCategoryFilter();
        new MetadataService.renameMetadataResponse_element();
        new MetadataService.cancelDeploy_element();
        new MetadataService.CancelDeployResult();
        new MetadataService.cancelDeployResponse_element();
        new MetadataService.DeleteResult();
        new MetadataService.upsertMetadata_element();
        new MetadataService.upsertMetadataResponse_element();
        new MetadataService.ReadReportFolderResult();
        new MetadataService.readReportFolderResponse_element();
        new MetadataService.UpsertResult();
        new MetaDataService.deployRecentValidation_element();
        new MetaDataService.DescribeValueTypeResult();
        new MetaDataService.AllOrNoneHeader_element();
        
    }

    @IsTest
    private static void elfMissingGetRecordsTest() { // elf patch
    
        new MetadataService.ReadFolderResult().getRecords();
        new MetadataService.ReadReportFolderResult().getRecords();
        new MetadataService.ReadReportTypeResult().getRecords();
        new MetadataService.ReadReportResult().getRecords();
        
    }

    @IsTest
    private static void elfMissingGetResultTest() { // elf patch
          
        new MetadataService.readReportTypeResponse_element().getResult();
        new MetadataService.readReportResponse_element().getResult();
        new MetadataService.readFolderResponse_element().getResult();
        new MetadataService.readReportFolderResponse_element().getResult();
        
    }    
}