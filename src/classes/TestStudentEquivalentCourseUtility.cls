/***************************************************************************************
 * Author: Brad King
 * Western Governors University 
 *
 * Purpose: Test StudentEquivalentCourseUtility
 *
 * Revisions:
 *     4-23-2013 - Created Class 
 *     10/8/2013 - PBC commented out User record creation, replaced with active User lookup for test runs
 *
 ***************************************************************************************/

@isTest
private with sharing class TestStudentEquivalentCourseUtility
{
    private static testMethod void testInsert()
    {
        // Create mentor test user
        //Id profileId = [SELECT Id FROM Profile WHERE Name = 'Mentor' LIMIT 1].Id;
        
        User testUser = [SELECT id from User where isActive = true AND Profile.Name = 'Mentor' LIMIT 1]; //new User();
        /*
        testUser.Firstname = 'TestFEPlEm';
        testUser.Lastname = 'UserFEPlEm';
        testUser.Pidm__c = 'QA95050QA';
        testUser.Username = 'testuserFEPlEm@testuser.testuser';
        testUser.Email = 'testuserFEPlEm@testuser.testuser.wgu.edu';
        testUser.Alias = 'testFEPl';
        testUser.CommunityNickname = 'testua6123se';
        testUser.TimeZoneSidKey = 'America/Denver';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';     
        insert testUser;
        */
        RecordType trDegRT = [SELECT Id FROM RecordType WHERE SObjectType = 'KeyValue__c' AND DeveloperName = 'TransferDegree' LIMIT 1];
        RecordType eqCrsRT = [SELECT Id FROM RecordType WHERE SObjectType = 'TranscriptToBanner__c' AND DeveloperName = 'StudentEquivalentCourse' LIMIT 1];
        
        KeyValue__c noDegree = new KeyValue__c(RecordTypeId = trDegRT.Id, ExternalID__c = 'ND', Value__c = 'ND', NumericValue__c = 0);
        insert noDegree;         
            
        CAREProgram__c testCAREProgram = new CAREProgram__c(Name = 'TestCAREProgram124');
        insert testCAREProgram;
        
        WGUDegreeProgram__c testWGUDegreeProgram = new WGUDegreeProgram__c(Name = 'TestWGUDegreeProgram124', PAMSID__c = 124124124, Active__c = true, CatalogTerm__c = '201106');
        WGUDegreeProgram__c testWGUDegreeProgram1 = new WGUDegreeProgram__c(Name = 'TestWGUDegreeProgram124', PAMSID__c = 124124125, Active__c = true, CatalogTerm__c = '201206');
        WGUDegreeProgram__c testWGUDegreeProgram2 = new WGUDegreeProgram__c(Name = 'TestWGUDegreeProgram124', PAMSID__c = 124124126, Active__c = false, CatalogTerm__c = '201306');
        insert testWGUDegreeProgram;
        insert testWGUDegreeProgram1;
        insert testWGUDegreeProgram2;
        
        WGUCourse__c testWGUCourse1 = new WGUCourse__c(Name = 'TestWGUCourse1', PAMSID__c = 1241241241);
        WGUCourse__c testWGUCourse2 = new WGUCourse__c(Name = 'TestWGUCourse2', PAMSID__c = 1241241242);        
        insert testWGUCourse1;
        insert testWGUCourse2;
        
        testWGUCourse1 = [SELECT Id, Name FROM WGUCourse__c WHERE Name = 'TestWGUCourse1' LIMIT 1];
        testWGUCourse2 = [SELECT Id, Name FROM WGUCourse__c WHERE Name = 'TestWGUCourse2' LIMIT 1];
        
        WGUCourseInProgram__c testWGUCourseInProgram1 = new WGUCourseInProgram__c(Course__c = testWGUCourse1.Id, Program__c = testWGUDegreeProgram1.Id, Transferable__c = true);
        WGUCourseInProgram__c testWGUCourseInProgram2 = new WGUCourseInProgram__c(Course__c = testWGUCourse2.Id, Program__c = testWGUDegreeProgram1.Id, Transferable__c = true);        
        insert testWGUCourseInProgram1; 
        insert testWGUCourseInProgram2;
        
        CAREProgramMiddleEarth__c testCAREProgramMiddleEarth = new CAREProgramMiddleEarth__c(CareProgramCode__c = testCAREProgram.Id, BannerProgramCode__c = testWGUDegreeProgram.Id);
        insert testCAREProgramMiddleEarth;
        
        Opportunity testOpportunity = new Opportunity(Name = 'testEvalCourseTriggerOpp', CloseDate = Date.Today(), StageName = 'Applicant', 
                                                      MarketingReferID__c = '549519sdfa8', MarketingProgram__c = testCAREProgramMiddleEarth.Id);
        insert testOpportunity;                
        
        TransferEvaluation__c testTransferEvaluation = new TransferEvaluation__c(Name = 'testTransferEval124', Opportunity__c = testOpportunity.Id, 
                                                                                 EligibilityStatus__c = 'Eligible', EvaluationStatus__c = 'Pending');
        testTransferEvaluation.assignedTo__c = testUser.Id;                                                                                
        insert testTransferEvaluation;
        //Trigger just created 2 equivalent courses 
        
        List<StudentEquivalentCourse__c> eqCrss = [SELECT Id, Name, TransferEvaluation__c FROM StudentEquivalentCourse__c LIMIT 20];
        
        for (StudentEquivalentCourse__c eqCrs : eqCrss)
        {
            System.debug('=====> ' + eqCrs + ' ' + testTransferEvaluation.Id);
        }               
        
        testTransferEvaluation = [SELECT Name, Opportunity__c, EvaluationStatus__c, WGUDegreeProgram__c FROM TransferEvaluation__c WHERE Id = :testTransferEvaluation.Id LIMIT 1];
        
        StudentTranscript__c testTranscript = new studentTranscript__c(Opportunity__c = testOpportunity.Id);
        insert testTranscript;                
        
        StudentTransferredCourse__c transCourse1 = new studentTransferredCourse__c(StudentTransferInstitution__c = testTranscript.Id);
        StudentTransferredCourse__c transCourse2 = new studentTransferredCourse__c(StudentTransferInstitution__c = testTranscript.Id); 
        insert transCourse1;
        insert transCourse2;                    
        
        StudentEquivalentCourse__c equivCourse1 = new studentEquivalentCourse__c(TransferEvaluation__c = testTransferEvaluation.Id, 
                                                                                 TransferredCourse__c = transCourse1.Id,
                                                                                 RequirementSatisfied__c = true,
                                                                                 PushedToBanner__c = true);
        StudentEquivalentCourse__c equivCourse2 = new studentEquivalentCourse__c(TransferEvaluation__c = testTransferEvaluation.Id, 
                                                                                 TransferredCourse__c = transCourse2.Id,
                                                                                 RequirementSatisfied__c = true,
                                                                                 PushedToBanner__c = true);                                                                                                                                                                                                                                                                                                                             
        
        Test.startTest(); 
        
            insert equivCourse1;    
            insert equivCourse2;  
        
        Test.stopTest();
        
        List<TranscriptToBanner__c> testTransToBanList = [SELECT Id, StudentEquivalentCourse__c, StudentTransferredCourse__c, ActionNeeded__c
                                                          FROM TranscriptToBanner__c
                                                          WHERE StudentEquivalentCourse__c != null 
                                                          LIMIT 20];
        
        System.debug('====> control size ' + testTransToBanList.size());
        
        Integer foundEq1 = 0;
        Integer foundEq2 = 0;               
        
        for (TranscriptToBanner__c testTransToBan : testTransToBanList)
        {
            System.assertEquals(testTransToBan.ActionNeeded__c, 'Insert');
            
            if (testTransToBan.StudentEquivalentCourse__c == equivCourse1.Id)
            {
                foundEq1 += 1;
            }
            else if (testTransToBan.StudentEquivalentCourse__c == equivCourse2.Id)
            {
                foundEq2 += 1;                
            }
        }
        
        System.assertEquals(foundEq1, 1);
        System.assertEquals(foundEq2, 1);
        
        update equivCourse1;              
        
        delete equivCourse1;
        
        testTransToBanList = [SELECT Id, StudentEquivalentCourse__c, StudentTransferredCourse__c, ActionNeeded__c         
                              FROM TranscriptToBanner__c
                              WHERE RefId__c = :equivCourse1.Id
                              LIMIT 1];
                              
        System.assertEquals(testTransToBanList[0].ActionNeeded__c, 'Delete');                                                                                               
    }
}