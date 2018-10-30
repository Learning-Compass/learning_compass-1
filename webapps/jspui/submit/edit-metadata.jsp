<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="java.sql.SQLException"%>


<%@page import="org.dspace.compass.association.engine.CompassBasicPopulator"%>
<%@page import="org.dspace.compass.association.engine.CompassLoInstanceFormPopulator"%>

<%@page import="org.dspace.compass.schema.form.LOInstanceFormDb"%>

<%@page import="org.dspace.compass.schema.form.LOInstanceFormAction"%>
<%@page import="org.dspace.compass.association.util.Tupple2"%>


<%@page import="org.dspace.content.Community"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.function.Predicate"%>
<%@page import="java.util.function.Consumer"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.function.Function"%>
<%@page import="java.util.function.BiFunction"%>
<%@page import="org.dspace.content.DSpaceObject"%>
<%@page import="org.dspace.content.ItemIterator"%>
<%@page import="org.dspace.content.Collection"%>
<%--
  - Edit metadata form
  -
  - Attributes to pass in to this page:
  -    submission.info   - the SubmissionInfo object
  -    submission.inputs - the DCInputSet
  -    submission.page   - the step in submission
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.dspace.eperson.EPerson" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="javax.servlet.jsp.tagext.TagSupport" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.ServletException" %>

<%@page import="org.dspace.content.Metadatum" %>


<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.jsptag.PopupTag" %>
<%@ page import="org.dspace.app.util.DCInput" %>
<%@ page import="org.dspace.app.util.DCInputSet" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.DCLanguage" %>
<%@ page import="org.dspace.content.DCPersonName" %>
<%@ page import="org.dspace.content.DCSeriesNumber" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.authority.MetadataAuthorityManager" %>
<%@ page import="org.dspace.content.authority.ChoiceAuthorityManager" %>
<%@ page import="org.dspace.content.authority.Choices" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.Utils" %>

<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.webui.submit.JSPStepManager" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.app.util.SubmissionStepConfig" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%

	EPerson user = (EPerson) request.getAttribute("dspace.current.user");
	String fullname = null;
    if (user != null)
    {
        fullname = user.getFirstName()+"  "+user.getLastName();
		//out.print("email:"+navbarEmail);
    }
	

    request.setAttribute("LanguageSwitch", "hide");
%>

<% pageContext.setAttribute("hitCounter", 1);

	 int pn=10;
	 
	 
	 //out.print("Param__"+pageContext.getRequest().getParameter("check")+"||Pagenum__"+pageContext.getRequest().getParameter("pagenum")+"||Page__"+pageContext.getRequest().getParameter("page")+"||stp:"+pageContext.getRequest().getParameter("step"));
 %>
<%
    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    SubmissionInfo si = SubmissionController.getSubmissionInfo(context, request);

    //COMPASS ASSOCIATION ENGINE DEPENDENCY...
    String collectionHandle = si.getCollectionHandle();
	session.setAttribute("collectionHandle",collectionHandle);
   // out.println("collection handle = " + collectionHandle);
	
    /*----------------------*/

    Item item = si.getSubmissionItem().getItem();

    final int halfWidth = 23;
    final int fullWidth = 50;
    final int twothirdsWidth = 34;

    DCInputSet inputSet
            = (DCInputSet) request.getAttribute("submission.inputs");

    Integer pageNumStr
            = (Integer) request.getAttribute("submission.page");
    int pageNum = pageNumStr.intValue();

    // for later use, determine whether we are in submit or workflow mode
    String scope = si.isInWorkflow() ? "workflow" : "submit";

    // owning Collection ID for choice authority calls
    Collection collection = si.getSubmissionItem().getCollection();
    int collectionID = collection.getID();

    // Fetch the document type (dc.type)
    String documentType = "";
    if ((item.getMetadataByMetadataString("dc.type") != null) && (item.getMetadataByMetadataString("dc.type").length > 0)) {
        documentType = item.getMetadataByMetadataString("dc.type")[0].value;
    }

    

%>

<c:set var="dspace.layout.head.last" scope="request">
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/scriptaculous/prototype.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/scriptaculous/builder.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/scriptaculous/effects.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath()%>/static/js/scriptaculous/controls.js"></script>
</c:set>
<dspace:layout style="submission" locbar="off" navbar="off" titlekey="jsp.submit.edit-metadata.title">

    <%
        contextPath = request.getContextPath();
    %>



    <form action="<%= request.getContextPath()%>/submit#<%= si.getJumpToField()%>" method="post" name="edit_metadata" id="edit_metadata" onkeydown="return disableEnterKey(event);">

        <jsp:include page="/submit/progressbar.jsp"></jsp:include>

            <h1><fmt:message key="jsp.submit.edit-metadata.heading"/>
            <%
                //figure out which help page to display
                if (pageNum <= 1) {
            %>
            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#describe2\"%>"><fmt:message key="jsp.submit.edit-metadata.help"/></dspace:popup>
                <%
                     }
                     else
                     {
                %>
            <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#describe3\"%>"><fmt:message key="jsp.submit.edit-metadata.help"/></dspace:popup>
                <%
                     }
                %>
        </h1>

        <%
             //figure out which help page to display
             if (pageNum <= 1) {
        %>
        <p><fmt:message key="jsp.submit.edit-metadata.info1"/></p>
        <%
        } else {
        %>
        <p><fmt:message key="jsp.submit.edit-metadata.info2"/></p>

        <%
            }
			
			
					
			    SubmissionStepConfig currentStepConfig = SubmissionController.getCurrentStepConfig(request, si);
	int currentPage = AbstractProcessingStep.getCurrentPage(request);

	//get last step & page reached
	int stepReached = SubmissionController.getStepReached(si);
	int pageReached = JSPStepManager.getPageReached(si);
String doi="ok";
    // Are we in workflow mode?
    boolean workflowMode = false;
    if (currentPage == pageReached)
    {
        workflowMode = true;
    }

            int pageIdx = pageNum - 1;
            DCInput[] inputs = inputSet.getPageRows(pageIdx, si.getSubmissionItem().hasMultipleTitles(),
                    si.getSubmissionItem().isPublishedBefore());
            for (int z = 0; z < inputs.length; z++) {
                boolean readonly = false;
//out.print(inputs.length+"sss<hr>");
                // Omit fields not allowed for this document type
                if (!inputs[z].isAllowedFor(documentType)) {
                    continue;
                }

                // ignore inputs invisible in this scope
                if (!inputs[z].isVisible(scope)) {
                    if (inputs[z].isReadOnly(scope)) {
                        readonly = true;
                    } else {
                        continue;
                    }
                }
                String dcElement = inputs[z].getElement();
                String dcQualifier = inputs[z].getQualifier();
                String dcSchema = inputs[z].getSchema();

                String fieldName;
                int fieldCountIncr;
                boolean repeatable;
                String vocabulary;
                boolean required;

                vocabulary = inputs[z].getVocabulary();
                required = inputs[z].isRequired();

                if (dcQualifier != null && !dcQualifier.equals("*")) {
                    fieldName = dcSchema + "_" + dcElement + '_' + dcQualifier;
                } else {
                    fieldName = dcSchema + "_" + dcElement;
                }

                if ((si.getMissingFields() != null) && (si.getMissingFields().contains(fieldName))) {
                    if (inputs[z].getWarning() != null) {
                        if (si.getJumpToField() == null || si.getJumpToField().length() == 0) {
                            si.setJumpToField(fieldName);
                        }

                        String req = "<div class=\"alert alert-warning\">"
                                + inputs[z].getWarning()
                                + "<a name=\"" + fieldName + "\"></a></div>";
                        out.write(req);
                    }
                } else {
                    //print out hints, if not null
                    if (inputs[z].getHints() != null) {
        %>
        <div class="help-block">
            <%= inputs[z].getHints()%>
            <%
                if (hasVocabulary(vocabulary) && !readonly) {
            %>
			
            <span class="pull-right">
                <dspace:popup page="/help/index.html#controlledvocabulary">Help</dspace:popup>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </span>
            <%
                }
            %>
        </div>
        <%
                    }
                }

                repeatable = inputs[z].getRepeatable();
                fieldCountIncr = 0;
                if (repeatable && !readonly) {
                    fieldCountIncr = 1;
                    if (si.getMoreBoxesFor() != null && si.getMoreBoxesFor().equals(fieldName)) {
                        fieldCountIncr = 2;
                    }
                }

                String inputType = inputs[z].getInputType();
                String label = inputs[z].getLabel();
                boolean closedVocabulary = inputs[z].isClosedVocabulary();

                if (inputType.equals("name")) {
                    doPersonalName(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, fieldCountIncr, label, pageContext, collectionID);
                } else if (isSelectable(fieldName)) {
                    doChoiceSelect(out, pageContext, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, inputs[z].getPairs(), label, collectionID);
                } else if (inputType.equals("date")) {
                    doDate(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, fieldCountIncr, label, pageContext, request);
                } else if (inputType.equals("series")) {
                    doSeriesNumber(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, fieldCountIncr, label, pageContext);
                } else if (inputType.equals("qualdrop_value")) {
                    doQualdropValue(out, item, fieldName, dcSchema, dcElement, inputSet, repeatable, required,
                            readonly, fieldCountIncr, inputs[z].getPairs(), label, pageContext);
                } else if (inputType.equals("textarea")) {


                    //modified for compass....
                    doTextArea(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, fieldCountIncr, label, pageContext, vocabulary,
                            closedVocabulary, collectionID, pageNum, context);


                } else if (inputType.equals("dropdown")) {

                    /*COMMENT TO REMOVE IN PRODUCTION....*/
                    //if (pageNum == 2 || pageIdx == 1) {
                    //out.println("<bold>CONSTRUCTING DROPDOWN ASSOCIATION...</bold>");
                    //}
                    
                    //modified for compas....
                    doDropDown(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, inputs[z].getPairs(), label, pageNum, collection, collectionHandle, item);
                    
                } else if (inputType.equals("twobox")) {
                    doTwoBox(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, fieldCountIncr, label, pageContext,
                            vocabulary, closedVocabulary);
                } else if (inputType.equals("list")) {
                    doList(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, inputs[z].getPairs(), label);
                } else {

                    //modified for compass....
                    doOneBox(out, item, fieldName, dcSchema, dcElement, dcQualifier,
                            repeatable, required, readonly, fieldCountIncr, label, pageContext, vocabulary,
                            closedVocabulary, collectionID, pageNum, context,workflowMode,fullname);
                }

            } // end of 'for rows'
			
        %>
<% pageContext.setAttribute("hitCounter", hitsCount+1);

	 
		//out.print("visit"+pageContext.getAttribute("hitCounter"));
	//	out.print("apge"+pn);
//		out.print("param"+pageContext.getRequest().getParameter("check")+"//Page"+pageNumber);

 %>
        <%-- Hidden fields needed for SubmissionController servlet to know which item to deal with --%>
        <%= SubmissionController.getSubmissionParameters(context, request)%>
		
	
		
        <div class="row">
            <%  //if not first page & step, show "Previous" button
    if (!(SubmissionController.isFirstStep(request, si) && pageNum <= 1)) {%>

            <div class="col-md-6 pull-right btn-group">
                <input class="btn btn-default col-md-4" type="submit" name="<%=AbstractProcessingStep.PREVIOUS_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.previous"/>" />
                       <input class="btn btn-default col-md-4" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.cancelsave"/>"/>
                       <input class="btn btn-primary col-md-4" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.next"/>"/>
                       <%  } else {%>
                       <div class="col-md-4 pull-right btn-group">
                    <input class="btn btn-default col-md-6" type="submit" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.cancelsave"/>"/>
                           <input class="btn btn-primary col-md-6" type="submit" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.next"/>"/>
                           <%  }%>
                </div><br/>
            </div>    		
    </form>

</dspace:layout>
