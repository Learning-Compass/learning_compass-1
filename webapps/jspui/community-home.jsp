<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Community home JSP
  -
  - Attributes required:
  -    community             - Community to render home page for
  -    collections           - array of Collections in this community
  -    subcommunities        - array of Sub-communities in this community
  -    last.submitted.titles - String[] of titles of recently submitted items
  -    last.submitted.urls   - String[] of URLs of recently submitted items
  -    admin_button - Boolean, show admin 'edit' button
  --%>

  
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>

<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.*" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@page import="java.sql.*"%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Vector"%>
<%@page import="java.util.TreeMap"%>
<%@page import="java.util.Map.Entry"%>








<%

    // Retrieve attributes
    Community community = (Community) request.getAttribute( "community" );
    Collection[] collections =
        (Collection[]) request.getAttribute("collections");
    Community[] subcommunities =
        (Community[]) request.getAttribute("subcommunities");
    
    RecentSubmissions rs = (RecentSubmissions) request.getAttribute("recently.submitted");
    
    Boolean editor_b = (Boolean)request.getAttribute("editor_button");
    boolean editor_button = (editor_b == null ? false : editor_b.booleanValue());
    Boolean add_b = (Boolean)request.getAttribute("add_button");
    boolean add_button = (add_b == null ? false : add_b.booleanValue());
    Boolean remove_b = (Boolean)request.getAttribute("remove_button");
    boolean remove_button = (remove_b == null ? false : remove_b.booleanValue());

	// get the browse indices
    BrowseIndex[] bis = BrowseIndex.getBrowseIndices();

    // Put the metadata values into guaranteed non-null variables
    String name = community.getMetadata("name");
    String intro = community.getMetadata("introductory_text");
    String copyright = community.getMetadata("copyright_text");
    String sidebar = community.getMetadata("side_bar_text");
    Bitstream logo = community.getLogo();
    
    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        feedData = "comm:" + ConfigurationManager.getProperty("webui.feed.formats");
    }
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>


<%
int custom_total_items = 0;
String url = "jdbc:postgresql://localhost:5432/dspace";
		Connection con;
		ResultSet rst;
	


//out.println(sqlstr);
	
	HashMap<Integer,String> handlemap = new HashMap<Integer,String>();
      HashMap<Integer,String> namemap = new HashMap<Integer,String>();
	  HashMap<Integer,String> authorname = new HashMap<Integer,String>();
	  HashMap<Integer,String> ncoll = new HashMap<Integer,String>();
    
			con = DriverManager.getConnection(url,"dspace", "dspace");

			Statement st = con.createStatement();
		
//handle	
String sqlhandle = "select handle,resource_id from handle";	
			rst = st.executeQuery(sqlhandle);

			while(rst.next())
			{
				handlemap.put(rst.getInt(2),rst.getString(1));
			}
			
     			rst.close();
				
				
				
				
//name



String sqlstr2 = "select a.text_value,a.resource_id from metadatavalue a,collection2item b, "+
"community2collection c,community2community d,metadatavalue e "+
"where a.resource_id=b.item_id and b.collection_id=c.collection_id "+
"and c.community_id=d.child_comm_id and d.parent_comm_id=e.resource_id "+
"and e.text_value like '"+name+"' and a.metadata_field_id in (64)";

				
rst = st.executeQuery(sqlstr2);

			while(rst.next())
			{
				namemap.put(rst.getInt(2),rst.getString(1));
			}
			
     			rst.close();
				
//author

String sqlstr3 = "select a.text_value,a.resource_id from metadatavalue a,collection2item b, "+
"community2collection c,community2community d,metadatavalue e "+
"where a.resource_id=b.item_id and b.collection_id=c.collection_id "+
"and c.community_id=d.child_comm_id and d.parent_comm_id=e.resource_id "+
"and e.text_value like '"+name+"' and a.metadata_field_id in (9)";
					
rst = st.executeQuery(sqlstr3);

			while(rst.next())
			{
				authorname.put(rst.getInt(2),rst.getString(1));
			}
			
     			rst.close();
				
								
				
			
//Instance - Specification 

String sql3="select distinct b.item_id,a.text_value from metadatavalue a,collection2item b "+
" where a.resource_id=b.collection_id and a.metadata_field_id=64 and a.resource_type_id=3";
			
		
			
rst = st.executeQuery(sql3);

			while(rst.next())
			{
				ncoll.put(rst.getInt(1),rst.getString(2));
			}
			
     			rst.close();
				
								
				
				
			st.close();
			con.close();
			
			
		 //out.print(handlemap.size()+":"+namemap.size()+":"+authorname.size()+":"+ncoll.size()+"<hr>");		
			
			
	List<Integer> keyList = new ArrayList<Integer>(namemap.keySet());		

		
		%>
		
		
		
		
		
		
		
		
	


<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet"%>
<dspace:layout locbar="commLink" title="<%= name %>" feedData="<%= feedData %>">
<div class="well">
<div class="row">
	<div class="col-md-8">
        <h2><%= name %>
        <%
            if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
            {
%>
                : [<%= ic.getCount(community) %>]
<%
            }
%>
		<small><fmt:message key="jsp.community-home.heading1"/></small>
        <a class="statisticsLink btn btn-info" href="<%= request.getContextPath() %>/handle/<%= community.getHandle() %>/statistics"><fmt:message key="jsp.community-home.display-statistics"/></a>
		</h2>
	</div>
<%  if (logo != null) { %>
     <div class="col-md-4">
     	<img class="img-responsive" alt="Logo" src="<%= request.getContextPath() %>/retrieve/<%= logo.getID() %>" />
     </div> 
<% } %>
 </div>

<% if (StringUtils.isNotBlank(intro)) { %>
  <%= intro %>
<% } %>
</div>
<p class="copyrightText"><%= copyright %></p>
	<div class="row">
<%
	if (rs != null)
	{ %>
	<div class="col-md-8">
        <div class="panel panel-primary">        
        <div id="recent-submissions-carousel" class="panel-heading carousel slide">
        <%-- Recently Submitted items --%>
			<h3><fmt:message key="jsp.community-home.recentsub"/>
<%
    if(feedEnabled)
    {
    	String[] fmts = feedData.substring(5).split(",");
    	String icon = null;
    	int width = 0;
    	for (int j = 0; j < fmts.length; j++)
    	{
    		if ("rss_1.0".equals(fmts[j]))
    		{
    		   icon = "rss1.gif";
    		   width = 80;
    		}
    		else if ("rss_2.0".equals(fmts[j]))
    		{
    		   icon = "rss2.gif";
    		   width = 80;
    		}
    		else
    	    {
    	       icon = "rss.gif";
    	       width = 36;
    	    }
%>
    <a href="<%= request.getContextPath() %>/feed/<%= fmts[j] %>/<%= community.getHandle() %>"><img src="<%= request.getContextPath() %>/image/<%= icon %>" alt="RSS Feed" width="<%= width %>" height="15" style="margin: 3px 0 3px" /></a>
<%
    	}
    }
%>
			</h3>
		
	<%
		Item[] items = rs.getRecentSubmissions();
		boolean first = true;
		if(items!=null && items.length>0) 
		{ 
	%>	
		<!-- Wrapper for slides -->
		  <div class="carousel-inner">
	<%	for (int i = 0; i < items.length; i++)
		{
			Metadatum[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
			String displayTitle = "Untitled";
			if (dcv != null)
			{
				if (dcv.length > 0)
				{
					displayTitle = Utils.addEntities(dcv[0].value);
				}
			}
			%>
		    <div style="padding-bottom: 50px; min-height: 200px;" class="item <%= first?"active":""%>">
		      <div style="padding-left: 80px; padding-right: 80px; display: inline-block;"><%= StringUtils.abbreviate(displayTitle, 400) %> 
		      	<a href="<%= request.getContextPath() %>/handle/<%=items[i].getHandle() %>" class="btn btn-success">See</a>
		      </div>
		    </div>
<%
				first = false;
		     }
		%>
		</div>
		
		  <!-- Controls -->
		  <a class="left carousel-control" href="#recent-submissions-carousel" data-slide="prev">
		    <span class="icon-prev"></span>
		  </a>
		  <a class="right carousel-control" href="#recent-submissions-carousel" data-slide="next">
		    <span class="icon-next"></span>
		  </a>

          <ol class="carousel-indicators">
		    <li data-target="#recent-submissions-carousel" data-slide-to="0" class="active"></li>
		    <% for (int i = 1; i < rs.count(); i++){ %>
		    <li data-target="#recent-submissions-carousel" data-slide-to="<%= i %>"></li>
		    <% } %>
	      </ol>
		
		<%
		}
		%>
		  
     </div></div></div>
<%
	}
%>
	<div class="col-md-4">
    	<%= sidebar %>
	</div>
</div>	

<%-- Browse --%>


<div class="row">

    <%
    	int discovery_panel_cols = 12;
    	int discovery_facet_cols = 4;
    %>
	<%@ include file="discovery/static-sidebar-facet.jsp" %>
</div>

<div class="row">
	<%@ include file="discovery/static-tagcloud-facet.jsp" %>
</div>
	
<div class="row">
<%
	boolean showLogos = ConfigurationManager.getBooleanProperty("jspui.community-home.logos", true);
	if (subcommunities.length != 0)
    {
%>
	<div class="col-md-6">

		<h3>Learning Opportunities</h3>
   
        <div class="list-group">
	
		
		
		
		<table align="center" class="table" summary="This table browses all dspace content">
<colgroup><col width="130"><col width="60%"><col width="40%"></colgroup>
<tbody><tr>
<th id="t1" class="oddRowOddCol"><strong>Title</strong></th><th id="t2" class="oddRowEvenCol">Author</th>
<th id="t3" class="oddRowEvenCol">Type</th>
</tr>
<%

String s;
String hd = "";
String nm ="";
String anm ="";
String cnm ="";
for (Integer temp : keyList) {
		hd = (String) handlemap.get(temp);
		nm = (String) namemap.get(temp);
		anm = (String) authorname.get(temp);
		cnm = (String) ncoll.get(temp);	
		
%>
<tr>
<td headers="t1" class="evenRowOddCol">
<strong><a href="<%out.print(request.getContextPath()+"/handle/"+hd);%>"><%= nm%></a></strong></td>
<td headers="t2" class="evenRowOddCol"><strong><%= anm%></strong></td>
<td headers="t2" class="evenRowOddCol"><strong><%= cnm%></strong></td>
</tr>
<%}%>

</tbody></table>

			
   </div>
</div>
<%
    }
%>

<%
    if (collections.length != 0)
    {
%>
	<div class="col-md-6">

        <%-- <h2>Collections in this community</h2> --%>
		<h3><fmt:message key="jsp.community-home.heading2"/></h3>
		<div class="list-group">
<%
        for (int i = 0; i < collections.length; i++)
        {
%>
			<div class="list-group-item row">  
<%  
		Bitstream logoCol = collections[i].getLogo();
		if (showLogos && logoCol != null) { %>
			<div class="col-md-3">
		        <img alt="Logo" class="img-responsive" src="<%= request.getContextPath() %>/retrieve/<%= logoCol.getID() %>" /> 
			</div>
			<div class="col-md-9">
<% } else { %>
			<div class="col-md-12">
<% }  %>		

	      <h4 class="list-group-item-heading"><a href="<%= request.getContextPath() %>/handle/<%= collections[i].getHandle() %>">
	      <%= collections[i].getMetadata("name") %></a>
<%
            if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
            {
%>
                [<%= ic.getCount(collections[i]) %>]
<%
            }
%>
	    <% if (remove_button) { %>
	      <form class="btn-group" method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
	          <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
	          <input type="hidden" name="community_id" value="<%= community.getID() %>" />
	          <input type="hidden" name="collection_id" value="<%= collections[i].getID() %>" />
	          <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_DELETE_COLLECTION%>" />
	          <button type="submit" class="btn btn-xs btn-danger"><span class="glyphicon glyphicon-trash"></span></button>
	      </form>
	    <% } %>
		</h4>
      <p class="collectionDescription"><%= collections[i].getMetadata("short_description") %></p>
    </div>
  </div>  
<%
        }
%>
  </div>
</div>
<%
    }
%>
</div>
    <% if(editor_button || add_button)  // edit button(s)
    { %>
    <dspace:sidebar>
		 <div class="panel panel-warning">
             <div class="panel-heading">
             	<fmt:message key="jsp.admintools"/>
             	<span class="pull-right">
             		<dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>"><fmt:message key="jsp.adminhelp"/></dspace:popup>
             	</span>
             	</div>
             <div class="panel-body">
             <% if(editor_button) { %>
	            <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
		          <input type="hidden" name="community_id" value="<%= community.getID() %>" />
		          <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_EDIT_COMMUNITY%>" />
                  <%--<input type="submit" value="Edit..." />--%>
                  <input class="btn btn-default col-md-12" type="submit" value="<fmt:message key="jsp.general.edit.button"/>" />
                </form>
             <% } %>
             <% if(add_button) { %>

				<form method="post" action="<%=request.getContextPath()%>/tools/collection-wizard">
		     		<input type="hidden" name="community_id" value="<%= community.getID() %>" />
                    <input class="btn btn-default col-md-12" type="submit" value="<fmt:message key="jsp.community-home.create1.button"/>" />
                </form>
                
                <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
                    <input type="hidden" name="action" value="<%= EditCommunitiesServlet.START_CREATE_COMMUNITY%>" />
                    <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
                    <%--<input type="submit" name="submit" value="Create Sub-community" />--%>
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.community-home.create2.button"/>" />
                 </form>
             <% } %>
            <% if( editor_button ) { %>
                <form method="post" action="<%=request.getContextPath()%>/mydspace">
                  <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                  <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_EXPORT_ARCHIVE %>" />
                  <input class="btn btn-default col-md-12" type="submit" value="<fmt:message key="jsp.mydspace.request.export.community"/>" />
                </form>
              <form method="post" action="<%=request.getContextPath()%>/mydspace">
                <input type="hidden" name="community_id" value="<%= community.getID() %>" />
                <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_MIGRATE_ARCHIVE %>" />
                <input class="btn btn-default col-md-12" type="submit" value="<fmt:message key="jsp.mydspace.request.export.migratecommunity"/>" />
              </form>
               <form method="post" action="<%=request.getContextPath()%>/dspace-admin/metadataexport">
                 <input type="hidden" name="handle" value="<%= community.getHandle() %>" />
                 <input class="btn btn-default col-md-12" type="submit" value="<fmt:message key="jsp.general.metadataexport.button"/>" />
               </form>
			<% } %>
			</div>
		</div>
  </dspace:sidebar>
    <% } %>
</dspace:layout>
