<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Progress bar for submission form.  Note this must be included within
  - the FORM element in the submission form, since it contains navigation
  - buttons.
  -
  - Parameters: None
  --%>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.webui.submit.JSPStepManager" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.util.SubmissionConfig" %>
<%@ page import="org.dspace.app.util.SubmissionStepConfig" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.apache.log4j.Logger" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%

String url = "jdbc:postgresql://localhost:5432/dspace";
		Connection con;
		ResultSet rst;
	


			con = DriverManager.getConnection(url,"dspace", "dspace");

			Statement st = con.createStatement();
			
			
	int flag=0;
		//collection	
String sqlhcol = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a where a.metadata_field_id in (64) "+
" and a.resource_id in (select distinct b.item_id from metadatavalue a,collection2item b "+
" where a.resource_id=b.collection_id and a.metadata_field_id=64 and a.resource_type_id=3 "+
" and b.item_id in (select item_id from community2collection col,item i "+
" where i.owning_collection=col.collection_id and collection_id= "+
" (select distinct c2c.collection_id from handle h, metadatavalue m, item i, community2collection c2c "+
" where h.handle like '"+session.getAttribute("collectionHandle").toString()+"' and m.resource_id=h.resource_id and m.resource_type_id=h.resource_type_id and "+
" i.owning_collection=m.resource_id and c2c.collection_id =i.owning_collection)) and a.text_value='Specifications')"	;


rst = st.executeQuery(sqlhcol);
			if(rst.next()) flag=1; else flag=0;
			
			rst.close();
st.close();
con.close();









String msg="";
    request.setAttribute("LanguageSwitch", "hide");

    /** log4j logger */
    Logger log = Logger.getLogger("progressbar.jsp");

	// Obtain DSpace context
    Context context = UIUtil.obtainContext(request);
    
    //get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

    //get configuration for our current Submission process
    SubmissionConfig subConfig = subInfo.getSubmissionConfig();
	
    //get configuration for our current step & page in submission process
    SubmissionStepConfig currentStepConfig = SubmissionController.getCurrentStepConfig(request, subInfo);
	int currentPage = AbstractProcessingStep.getCurrentPage(request);

	//get last step & page reached
	int stepReached = SubmissionController.getStepReached(subInfo);
	int pageReached = JSPStepManager.getPageReached(subInfo);

    // Are we in workflow mode?
    boolean workflowMode = false;
    if (stepReached == -1)
    {
        workflowMode = true;
    }
%>

<!--Progress Bar-->
<div class="row container btn-group">
<%    
    //get progress bar info, used to build progress bar
	HashMap progressBarInfo = (HashMap) subInfo.getProgressBarInfo();

    if((progressBarInfo!=null) && (progressBarInfo.keySet()!=null))
    {
	   //get iterator
	   Set keys = progressBarInfo.keySet();
	   Iterator barIterator = keys.iterator();

	   //loop through all steps & print out info     
       while(barIterator.hasNext())
        {
		  //this is a string of the form: stepNum.pageNum
	      String stepAndPage = (String) barIterator.next();
		
		  //get heading from hashmap
		  String heading = (String) progressBarInfo.get(stepAndPage);

		  //if the heading contains a period (.), then assume
          //it is referencing a key in Messages.properties
          if(heading.indexOf(".") >= 0)
          {
             //prepend the existing key with "jsp." since we are using JSP-UI
             heading = LocaleSupport.getLocalizedMessage(pageContext, "jsp." + heading);
          }

		  //split into stepNum and pageNum
		  String[] fields = stepAndPage.split("\\.");  //split on period
          int stepNum = Integer.parseInt(fields[0]);
		  int pageNum = Integer.parseInt(fields[1]);
          
		  //if anywhere in last step (i.e. submission is completed), disable EVERYTHING (not allowed to jump back)
		  if(stepReached >= subConfig.getNumberOfSteps())
          {
			 if(stepNum==subConfig.getNumberOfSteps())
			 {
			   // Show "Complete" step as the current step
    %>
               <input class="submitProgressButtonCurrent btn btn-primary" disabled="disabled" type="submit" name="<%=AbstractProcessingStep.PROGRESS_BAR_PREFIX + stepAndPage%>" value="<%=heading%>" />
    <%
             }
        	 else
        	 {
			   // submission is completed, so cannot jump back to any steps
    %>
               <input class="submitProgressButtonDone btn btn-success" disabled="disabled" type="submit" name="<%=AbstractProcessingStep.PROGRESS_BAR_PREFIX + stepAndPage%>" value="<%=heading%>" />
    <%
        	 }
           }
		   //if this is the current step & page, highlight it as "current"
		   else if((stepNum == currentStepConfig.getStepNumber()) && (pageNum == currentPage))
           {
			 
			if(flag==0)   {
				   if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}   
			   
			}
			else
			{
				     if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}   
				
			}
	         %>
		     <input class="submitProgressButtonCurrent btn btn-primary" disabled="disabled" type="submit" name="<%=AbstractProcessingStep.PROGRESS_BAR_PREFIX + stepAndPage%>" value="<%=msg%>" />
        	 <%
           }
		   else if(workflowMode) //if in workflow mode, can jump to any step/page
    	   {
			 
			 if(flag==0)   {
				   if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}   
			   
			}
			else
			{
				   if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}   
				
			}
			 
		     %>
            <input class="submitProgressButtonDone btn btn-success" type="submit" name="<%=AbstractProcessingStep.PROGRESS_BAR_PREFIX + stepAndPage%>" value="<%=msg%>" />
			 <%
    	   }
		  //else if this step & page has been completed
		  else if( (stepNum < stepReached) || ((stepNum == stepReached) && (pageNum <= pageReached)) )
    	  {
			  
			  	  if(flag==0)   {
				     if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}   
			   
			}
			else
			{
				    if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}    
				
			}
%>
            <input class="submitProgressButtonDone btn btn-info" type="submit" name="<%=AbstractProcessingStep.PROGRESS_BAR_PREFIX + stepAndPage%>" value="<%=msg%>" />
<%
          }
		  else //else this is a step that has not been done, yet
          {
			  	   	 
			  	  if(flag==0)   {
				     if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}   
			   
			}
			else
			{
				    if (stepAndPage.equals("2.1")) {msg="Selection of Specification";}
			   else if (stepAndPage.equals("2.2")) {msg="Technical Details";}
			   else if (stepAndPage.equals("2.3")) {msg="Competences - Outcomes";}
			   else if (stepAndPage.equals("2.4")) {msg="Educational Data";}
			   else if (stepAndPage.equals("2.5")) {msg="Associations";}
			   else if (stepAndPage.equals("3.1")) {msg="Select an image";}
			   else if (stepAndPage.equals("4.1")) {msg="Verify";}
			   else if (stepAndPage.equals("5.1")) {msg="Complete";}
			   else {msg="Description";}    
				
			}
            // Stage hasn't been completed yet (can't be jumped to)
%>
		    <input class="submitProgressButtonNotDone btn btn-default" disabled="disabled" type="submit" name="<%=AbstractProcessingStep.PROGRESS_BAR_PREFIX + stepAndPage%>" value="<%=msg%>" />
<%
          }
	   }//end while
   }
%>
        </div>
