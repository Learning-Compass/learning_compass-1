<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>

<%--
  - Display hierarchical list of communities and collections
  -
  - Attributes to be passed in:
  -    communities         - array of communities
  -    collections.map  - Map where a keys is a community IDs (Integers) and 
  -                      the value is the array of collections in that community
  -    subcommunities.map  - Map where a keys is a community IDs (Integers) and 
  -                      the value is the array of subcommunities in that community
  -    admin_button - Boolean, show admin 'Create Top-Level Community' button
  --%>

<%@page import="org.dspace.content.Bitstream"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
	
<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.ItemCountException" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Map" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>

<%@page import="java.util.Vector"%>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>


<script>
$(document).ready(function(){
    $('[data-toggle="popover"]').popover(); 
});
</script>



<%
out.print("yolo:");
    Community[] communities = (Community[]) request.getAttribute("communities");
    Map collectionMap = (Map) request.getAttribute("collections.map");
    Map subcommunityMap = (Map) request.getAttribute("subcommunities.map");
    Boolean admin_b = (Boolean)request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
	
		
				
%>

<%!
    void showCommunity(Community c, JspWriter out, HttpServletRequest request, ItemCounter ic,
    		Map collectionMap, Map subcommunityMap) throws ItemCountException, IOException, SQLException
    {
		
		int hd =0;
	String url = "jdbc:postgresql://localhost:5432/dspace";
		Connection con;
		ResultSet rst;
		ResultSet rseq;
		HashMap<Integer,Integer> collmap = new HashMap<Integer,Integer>();
		HashMap<Integer,String> handlemap = new HashMap<Integer,String>();
      HashMap<Integer,String> namemap = new HashMap<Integer,String>();
	  HashMap<Integer,String> authorname = new HashMap<Integer,String>();
	  HashMap<Integer,String> ncoll = new HashMap<Integer,String>();
	  HashMap<Integer,String> equivel = new HashMap<Integer,String>();
String vec_course="";    


			con = DriverManager.getConnection(url,"dspace", "dspace");

			Statement st = con.createStatement();
			Statement st_equiv = con.createStatement();
			
			
				
				
				//handle	
String sqlhandle = "select handle,resource_id from handle";	
			rst = st.executeQuery(sqlhandle);

			while(rst.next())
			{
				handlemap.put(rst.getInt(2),rst.getString(1));
			}
			
     			rst.close();
				


				
//equivelant				
				
 sqlhandle = "select count(*),a.resource_id from metadatavalue a,handle b where a.metadata_field_id in (40) and b.resource_id=a.resource_id  group by a.resource_id";	
			rst = st.executeQuery(sqlhandle);

			while(rst.next())
			{
				equivel.put(rst.getInt(2),rst.getString(1));
			}
			
     			rst.close();
//name



String sqlstr2 = "select a.text_value,a.resource_id from metadatavalue a,collection2item b, "+
"community2collection c,community2community d,metadatavalue e "+
"where a.resource_id=b.item_id and b.collection_id=c.collection_id "+
"and c.community_id=d.child_comm_id and d.parent_comm_id=e.resource_id "+
"and a.metadata_field_id in (64)";

				
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
"and a.metadata_field_id in (9)";
					
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
				
								
				
				
			
			
	

	
		List<Integer> keyList = new ArrayList<Integer>(namemap.keySet());			
		Vector <String> vec_equiv=new Vector <String>();
		
		
		
	

		boolean showLogos = ConfigurationManager.getBooleanProperty("jspui.community-list.logos", true);
        out.println( "<li class=\"media well\">" );
        Bitstream logo = c.getLogo();
        if (showLogos && logo != null)
        {
        	out.println("<a class=\"pull-left col-md-2\" href=\"" + request.getContextPath() + "/handle/" 
        		+ c.getHandle() + "\"><img class=\"media-object img-responsive\" src=\"" + 
        		request.getContextPath() + "/retrieve/" + logo.getID() + "\" alt=\"community logo\"></a>");
        }
        out.println( "<div class=\"media-body\"><h4 class=\"media-heading\"><a href=\"" + request.getContextPath() + "/handle/" 
        	+ c.getHandle() + "\">" + c.getMetadata("name") + "</a>");
        if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
        {
            out.println(" <span class=\"badge\">" + ic.getCount(c) + "</span>");
        }
		out.println("</h4>");
		if (StringUtils.isNotBlank(c.getMetadata("short_description")))
		{
			out.println(c.getMetadata("short_description"));
		}
		out.println("<br>");
        // Get the collections in this community
        Collection[] cols = (Collection[]) collectionMap.get(c.getID());
        if (cols != null && cols.length > 0)
        {
            out.println("<ul class=\"media-list\">");
            for (int j = 0; j < cols.length; j++)
            {
				int g = cols[j].getID();
				
				//collection	
String sqlhcol = "select item_id from collection2item where collection_id="+g;	

			rst = st.executeQuery(sqlhcol);
int col_id=0;
			while(rst.next())
			{
				
				
				
				col_id=rst.getInt(1);
				
				
				
String s;
String hdd = "";
String nm ="";
String anm ="";
String cnm ="";
int count_equiv =0;
int vec_size=0;

		hdd = (String) handlemap.get(col_id);
		nm = (String) namemap.get(col_id);
		
		anm = (String) authorname.get(col_id);
		cnm = (String) ncoll.get(col_id);	
		
		
				rseq=st_equiv.executeQuery("select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "+
"where a.metadata_field_id in (40) and b.resource_id=a.resource_id and b.handle='"+hdd+"'");
				while(rseq.next())
			{
				
				vec_equiv.addElement(rseq.getString(1));
			}
			rseq.close();
				
			
		

				//equivelant	
// "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "+
//"where a.metadata_field_id in (40) and b.resource_id=a.resource_id and b.handle='"+hdd+"'";

	




		
if (!cnm.equals("Specifications")){								
String tbl="<table align='center' class='table' summary='This table browses all dspace content'>"+
"<colgroup><col width='130'><col width='60%'><col width='40%'></colgroup>"+
"<tbody><tr>"+
"<th id='t1' class='oddRowOddCol'><strong>Title</strong></th><th id='t2' class='oddRowEvenCol'>Author</th>"+
"<th id='t3' class='oddRowEvenCol'>Equivelant</th>"+
"</tr>";
out.print(tbl);
		

String tbl1="<tr>"+
"<td headers='t1' class='evenRowOddCol'><strong><a href='"+request.getContextPath()+"/handle/"+hdd+"'>"+nm+"</a></strong></td>"+
"<td headers='t2' class='evenRowOddCol'><strong>"+ anm+"</strong></td>"+
"<td headers='t2' class='evenRowOddCol'><strong>";

if (vec_equiv.size()==0)
{
	tbl1=tbl1+"No_equivelant";
	
}

if (vec_equiv.size()>0)
{

for (int gh=0;gh<vec_equiv.size();gh++){

vec_course=vec_course+vec_equiv.elementAt(gh);
}
tbl1=tbl1+"<a href='#' data-toggle='popover' title='Department :: Course_Name' data-content='"+vec_course+"'>"+vec_equiv.size()+"</a><BR>";



vec_equiv.removeAllElements();
vec_course="";

}
tbl1=tbl1+"</a></strong></td>"+

"</tr>"+"</tbody></table>";

out.print(tbl1);
}
		
			}
			
     			rst.close();
				

				
				
		
			
			
			
				
				
              
            }
            out.println("</ul>");
        }

        // Get the sub-communities in this community
        Community[] comms = (Community[]) subcommunityMap.get(c.getID());
        
        if (comms != null && comms.length > 0)
        {
            out.println("<ul class=\"media-list\">");
            for (int k = 0; k < comms.length; k++)
            {
				
               showCommunity(comms[k], out, request, ic, collectionMap, subcommunityMap);
            }
            out.println("</ul>"); 
        }
        out.println("</div>");
        out.println("</li>");
		st.close();
			con.close();
    }
%>

<dspace:layout titlekey="jsp.community-list.title">

<%
    if (admin_button)
    {
%>     
<dspace:sidebar>
			<div class="panel panel-warning">
			<div class="panel-heading">
				<fmt:message key="jsp.admintools"/>
				<span class="pull-right">
					<dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>"><fmt:message key="jsp.adminhelp"/></dspace:popup>
				</span>
			</div>
			<div class="panel-body">
                <form method="post" action="<%=request.getContextPath()%>/dspace-admin/edit-communities">
                    <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_CREATE_COMMUNITY%>" />
					<input class="btn btn-default" type="submit" name="submit" value="<fmt:message key="jsp.community-list.create.button"/>" />
                </form>
            </div>
</dspace:sidebar>
<%
    }
%>
	<h1><fmt:message key="jsp.community-list.title"/></h1>
	<p><fmt:message key="jsp.community-list.text1"/></p>

<% if (communities.length != 0)
{
%>
    <ul class="media-list">
<%
        for (int i = 0; i < communities.length; i++)
        {
            showCommunity(communities[i], out, request, ic, collectionMap, subcommunityMap);
        }
%>
    </ul>
 
<% }
%>

</dspace:layout>
