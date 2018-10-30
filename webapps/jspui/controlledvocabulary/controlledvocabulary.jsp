<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
  
<%--
  -- This jsp is reponsible for displaying controlled vocabularies in a 
  -- popup window during the description phases of submitted items.
  -- This jsp holds the content of that popup window.
  --%>

  
<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Map" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>

<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>

<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.*" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<%


	String filter = (String)session.getAttribute("controlledvocabulary.filter");
	
	//String type_= (String) pageContext.getAttribute("type", PageContext.SESSION_SCOPE);
	

	filter = filter==null?"":filter;
	String ID = (String)request.getParameter("ID");
	
	if(request.getParameter("vocabulary")!=null) {
		session.setAttribute("controlledvocabulary.vocabulary", request.getParameter("vocabulary"));
	}
	String vocabulary = (String)session.getAttribute("controlledvocabulary.vocabulary");
	String ch=session.getAttribute("collectionHandle").toString();
	//String ses_type=pageContext.getAttribute("hitCounter").toString();
	
	
	
	
	HashMap<Integer,String> names = new HashMap<Integer,String>();
	HashMap<Integer,String> collection = new HashMap<Integer,String>();
	HashMap<Integer,Integer> collection_names = new HashMap<Integer,Integer>();
	HashMap<Integer,Integer> names_collection = new HashMap<Integer,Integer>();
	
	int hd =0;
	String url = "jdbc:postgresql://localhost:5432/dspace";
		Connection con;
		ResultSet rst;
	


			con = DriverManager.getConnection(url,"dspace", "dspace");

			Statement st = con.createStatement();
			
	
		//collection	
String sqlhcol = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a "+
"where a.metadata_field_id in (64) and a.resource_id in (select distinct b.item_id from metadatavalue a,collection2item b "+
"where a.resource_id=b.collection_id and a.metadata_field_id=64 and a.resource_type_id=3 and b.item_id in (select item_id from community2collection col,item i "+
"where i.owning_collection=col.collection_id and community_id= (select distinct c2c.community_id from handle h, metadatavalue m, item i, community2collection c2c "+
"where h.handle like '"+ch+"' and m.resource_id=h.resource_id  and m.resource_type_id=h.resource_type_id and i.owning_collection=m.resource_id "+
"and c2c.collection_id =i.owning_collection)) and a.text_value='Specifications')";	


String sql_col ="SELECT text_value,cm.child_comm_id FROM metadatavalue,community2community cm "+
"where metadata_field_id=27 and resource_type_id=4 and cm.parent_comm_id=resource_id and "+
" length(text_value)>0";	

String sql_name = "select a.text_value,a.resource_id from metadatavalue a  "+
"where a.metadata_field_id in (64) and a.resource_id in (select distinct b.item_id  "+
"from metadatavalue a,collection2item b "+
"where a.resource_id=b.collection_id and a.metadata_field_id=64  "+
"and a.resource_type_id=3 and b.item_id in (select item_id from community2collection col,item i  "+
"where i.owning_collection=col.collection_id and community_id in "+
"(SELECT cm.child_comm_id FROM metadatavalue,community2community cm "+
"where metadata_field_id=27 and resource_type_id=4 and cm.parent_comm_id=resource_id and "+
"length(text_value)>0)) and a.text_value='Specifications')";	

String sql_col_name = "select item_id,community_id from community2collection col,item i "+
"where i.owning_collection=col.collection_id order by owning_collection";	



rst = st.executeQuery(sql_col);
			while(rst.next())
			{
				collection.put(rst.getInt(2),rst.getString(1));
			}
			
			rst.close();
			
			
			
rst = st.executeQuery(sql_name);	

		while(rst.next())
			{
				names.put(rst.getInt(2),rst.getString(1));
				
			}
			
			rst.close();
			

rst = st.executeQuery(sql_col_name);


		while(rst.next())
			{
				collection_names.put(rst.getInt(2),rst.getInt(1));
				names_collection.put(rst.getInt(1),rst.getInt(2));
			}
			
			rst.close();
List<Integer> CommList = new ArrayList<Integer>(collection_names.keySet());
List<Integer> itemList = new ArrayList<Integer>(names_collection.keySet());

%>

<head> 
<%if (ID.startsWith("compass_learningOpportunitySpecification_prerequisite")||ID.startsWith("compass_learningOpportunity_prerequisite")) {%>
<title>Select Prerequisite Learning Opportunities </title>
<% } else if (ID.startsWith("dc_relation")) {%>
<title>Related Learning Opportunities</title>
<%}else {%>
<title><fmt:message key="jsp.controlledvocabulary.controlledvocabulary.title"/></title>
<%}%>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>


<link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon"/>
<link type="text/css" rel="stylesheet" href="<%= request.getContextPath() %>/styles.css"/>
 <link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/bootstrap.min.css" type="text/css" />
<link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/bootstrap-theme.min.css" type="text/css" />
<link rel="stylesheet" href="<%= request.getContextPath() %>/static/css/bootstrap/dspace-theme.css" type="text/css" />


<style type="text/css">
	body {background-color: #f4f4f4}
</style>
<script type='text/javascript' src="<%= request.getContextPath() %>/static/js/jquery/jquery-1.10.2.min.js"></script>
	<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/jquery/jquery-ui-1.10.3.custom.min.js'></script>
<script type='text/javascript' src='<%= request.getContextPath() %>/static/js/bootstrap/bootstrap.min.js'></script>
<script type="text/javascript" language="JavaScript" src="<%= request.getContextPath() %>/utils.js"></script>


  <script type="text/javascript">
	<%
		if(request.getParameter("ID")!=null) {
			session.setAttribute("controlledvocabulary.ID", request.getParameter("ID"));
		}
	%>

	<%-- This function is not included in scripts file 
	     because it has to be changed dynamically --%>

	function sendBackToParentWindow(node) {
		var resultPath = "";
		var firstNode = 1;
		var pathSeparator = "::";
		
		
		while(node != null) {
			if(firstNode == 1) {
				resultPath = getTextValue(node);
				firstNode = 0;
			} else {
				resultPath = getTextValue(node) + pathSeparator + resultPath;
			}
			node = getParentTextNode(node);
		}
		
		window.opener.document.edit_metadata.<%=session.getAttribute("controlledvocabulary.ID")%>.value= resultPath;
		
		self.close();
		return false;
	}
  </script>
</head>





<body class="subject-window">



<br/>

<div style="margin-left:10px">
<%if (ID.startsWith("compass_learningOpportunitySpecification_prerequisite")||ID.startsWith("compass_learningOpportunity_prerequisite")) {%>
 <h3>Specifications of learning opportunities</h3>
<%}else if (ID.startsWith("dc_relation")) {%>
 <h3>Specifications of learning opportunities</h3>
 <%}else if (ID.startsWith("dc_type")) {%>
 <h3>Select a Learning Type</h3>
<%}else {%>
<fmt:message key="jsp.controlledvocabulary.controlledvocabulary.trimmessage"/>
<%}%>
<!-- <table>

<tr>
<td class="pop-label"> -->
<!-- </td>

<td>  -->   
<div class="row">
    <span class="pop-label"><fmt:message key="jsp.controlledvocabulary.controlledvocabulary.filter"/></span>
	<form name="filterVocabulary" class="apply-form"
		  method="post" 
		  action="<%= request.getContextPath()%>/controlledvocabulary?ID=<%=request.getParameter("ID")%>">
	  
	  <input style="border-width:1px;border-style:solid;" class="form-control" name="filter" type="text" id="filter" size="35" value="<%= filter %>"/>
	  <input type="submit" class="btn btn-default" name="submit" value="<fmt:message key='jsp.controlledvocabulary.controlledvocabulary.trimbutton'/>"/>
	  <input type="hidden" name="ID" value="<%= ID %>"/>
	  <input type="hidden" name="action" value="filter"/>
	  <input type="hidden" name="callerUrl" value="<%= request.getContextPath()%>/controlledvocabulary/controlledvocabulary.jsp?ID=<%=request.getParameter("ID")%>"/>
	</form>
<!-- </td>
<td> -->
	<form name="clearFilter" method="post"  class="clear-form" action="<%= request.getContextPath() %>/controlledvocabulary?ID=<%=request.getParameter("ID")%>" >
	  <input type="hidden" name="ID" value="<%= ID %>"/>
	  <input type="hidden" name="filter" value=""/>
	  <input type="submit" class="btn btn-default" name="submit" value="<fmt:message key='jsp.controlledvocabulary.controlledvocabulary.clearbutton'/>"/>
	  <input type="hidden" name="action" value="filter"/> 
	  <input type="hidden" name="callerUrl" value="<%= request.getContextPath()%>/controlledvocabulary/controlledvocabulary.jsp?ID=<%=request.getParameter("ID")%>"/>
    </form>
</div>
<!-- </td>
</tr> -->
<%--
<tr>
<td colspan="3" class="submitFormHelpControlledVocabularies">
	<dspace:popup page="/help/index.html#controlledvocabulary"><fmt:message key="jsp.controlledvocabulary.controlledvocabulary.help-link"/></dspace:popup>
</td>
</tr>
--%>
<!-- </table> -->

</div>
<%if (ID.startsWith("compass_learningOpportunitySpecification_prerequisite")||ID.startsWith("compass_learningOpportunity_prerequisite")) {%>
<h1>Select a Learning Opportunity</h1>
<%}else if (ID.startsWith("dc_relation")) {%>
	<h1> Select an equivelant learning opportunity</h1>
	<%}else if (ID.startsWith("dc_type")) {%>
	<h1> Select the type of the Learning Type</h1>
<%}else {%>
<h1><fmt:message key="jsp.controlledvocabulary.controlledvocabulary.title"/></h1>
<%}%>

<ul class="controlledvocabulary">
<%

if (ID.startsWith("dc_relation")) {
	
	String co="";
for (Integer temp : CommList) {
		co = (String) collection.get(temp);

	%>

	
			<li>
<img class="controlledvocabulary" src="/jspui/image/controlledvocabulary/p.gif" onclick="ec(this, '/jspui');" alt="expand search term category"/>
<a href="javascript:void(null);" onclick="javascript: i(this);" class="value"><%=co%></a>
<ul class="controlledvocabulary">

<%
	String itm="";
	int itm_value;
	
for (Integer tmp : itemList) {
	itm = (String) names.get(tmp);	
	itm_value=names_collection.get(tmp);
	//out.print("tmp:"+tmp+"//temp"+temp+"//itm:"+itm+"//itm_value:"+itm_value+"<br>");
	//out.print(itm.equals("null")+"/<br>");
if	(itm_value==temp&& itm!= null ){
	
%>		
	<li>
<img class="dummyclass" src="/jspui/image/controlledvocabulary/f.gif" alt="search term"/>
<a href="javascript:void(null);" onclick="javascript: i(this);" class="value"><%=itm%></a>
</li>

	
<%}
}%>		
</ul>
</li>
<%}%>

</ul>


	
	<%
	//out.println("ID:"+ID+":");
	}
else if (ID.startsWith("compass_learningOpportunitySpecification_prerequisite")||ID.startsWith("compass_learningOpportunity_prerequisite")) {
	%>
<ul class="controlledvocabulary">
	<%
			rst = st.executeQuery(sqlhcol);
			while(rst.next())
			{
				
				%>
			<li>			
		<a href="javascript:void(null);" onclick="javascript: i(this);" class="value"><%=rst.getString(1)%></a>
	</li>
<%
			}	
     			rst.close();
%>
</ul>


	
	<%
	}	else{%>



<dspace:controlledvocabulary filter="<%= filter %>" vocabulary="<%= vocabulary %>"/> 
	<%}
	st.close();
			con.close();
	%>
<br/>
<center>
	<input type="button" name="cancel" class="btn btn-default" onclick="window.close();" value="<fmt:message key="jsp.controlledvocabulary.controlledvocabulary.closebutton"/>" />
</center>
</body>
</html>
