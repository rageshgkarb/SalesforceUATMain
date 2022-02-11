@isTest
global class MetadataServiceMockImpl implements WebServiceMock 
    {
        global void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.checkDeployStatus_element)
                response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.describeMetadata_element)
                response.put('response_x', new MetadataService.describeMetadataResponse_element());
            else if(request instanceof MetadataService.deploy_element)
                response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof MetadataService.readMetadata_element){
              
                MetadataService.readMetadata_element requestReadMetadata_element  = 
                                                (MetadataService.readMetadata_element) request;
      
                  // for report metadata read
                  if (requestReadMetadata_element.type_x == 'Report') { 
                     MetadataService.readReportResponse_element mockRes   = 
                          new MetadataService.readReportResponse_element();
                     mockRes.result = new MetaDataService.ReadReportResult();
                         
                    MetadataService.Report[] reports = new MetadataService.Report[]{};
                    MetadataService.Report report = new MetadataService.Report();
                    report.fullName = 'TestReportMarch2016';
                    report.Name = 'Test Report March 2016';
                    
                    MetadataService.ReportTimeFrameFilter timeFilter = 
                                            new MetadataService.ReportTimeFrameFilter();
                    
                    report.timeFrameFilter = timeFilter;
                    reports.add(report); 
                    mockRes.result.records = reports;
                    response.put('response_x', mockRes);
                  }
           
            }
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            
            return;
        }
 
    }