<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
  -    recent.submissions - RecetSubmissions
  --%>
    <script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBlS-I7gW2chgyqP-pVO09Gcu6e3AhOLfU&callback=initMap"
  type="text/javascript"></script>

<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.NewsManager" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
 <%@page import="java.util.Vector"%>
<%@page import="java.sql.*"%>

   <%
 
            String url = "jdbc:postgresql://localhost:5432/dspace";
            Connection con;
            ResultSet rst;

            con = DriverManager.getConnection(url, "dspace", "dspace");

            Statement st = con.createStatement();

 	
           
            Vector<String> country = new Vector<String>();
            Vector<String> courses = new Vector<String>();
			Vector<String> vurl = new Vector<String>();

         String   sqlhandle = "select count(*),loc from  ( select distinct title.text_value,  "
                 + "CASE WHEN location.text_value like'%Madrid%' THEN 'Spain'      "
                 + "      WHEN location.text_value='University of Montpellier' THEN 'France'     "
                 + "        WHEN location.text_value='TU Delft EMCS' THEN 'Netherland'        "
                 + "     WHEN location.text_value in('Politecnico di Torino','Turin') THEN 'Torino'  "
                 + "           WHEN location.text_value='Tallinn, Estonia' THEN 'tallinn'   "
                 + "          WHEN location.text_value like '%Athens%' THEN 'Athens'    "
                 + "    END loc,location.text_value lv from ( select a.text_value,a.resource_id,a.metadata_field_id,b.handle from "
                 + "metadatavalue a,handle b  where a.metadata_field_id in (39,138) and b.resource_id=a.resource_id  )"
                 + " location, (select a.text_value,a.resource_id from metadatavalue a where a.metadata_field_id in "
                 + "(64) and a.resource_id in (select a.resource_id from metadatavalue a,handle b "
                 + " where a.metadata_field_id in (39,138) and b.resource_id=a.resource_id ))title where"
                 + " location.resource_id=title.resource_id) x where loc is not null group by loc;";
            
            
            

            rst = st.executeQuery(sqlhandle);
    String str="";
            while (rst.next()) {
            
                courses.addElement(rst.getString(1));
                country.addElement(rst.getString(2));
                str=rst.getString(2);
			
				if(rst.getString(2).equals("Netherland")) str="delft";
				
				  vurl.addElement(str);
              
            }
			
			    st.close();
    con.close();

            String clr = "";

            String full = "";
            String kl = "";

      
            
        %>
	<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  <script>
    google.charts.load('current', { 'packages': ['map'] });
    google.charts.setOnLoadCallback(drawMap);

    function drawMap() {
      var data = google.visualization.arrayToDataTable([
          ['Country', 'Population', 'Url'],
        <%   for (int jj = 0; jj < country.size()-1; jj++) {%>
        ['<%= country.elementAt(jj) %>', '<% out.print(courses.elementAt(jj)+" Courses Available"); %>','<%= vurl.elementAt(jj) %>'],
    
        
<%}%>
    
     ['<%= country.elementAt(country.size()-1) %>', '<%= courses.elementAt(country.size()-1)+" Courses Available"%>','<%= vurl.elementAt(country.size()-1) %>']
      ]);

    var options = {
      showTooltip: true,
      showInfoWindow: true
    };

    var map = new google.visualization.Map(document.getElementById('chart_div'));
    google.visualization.events.addListener(map, 'select', function() {
        var selectionIdx = map.getSelection()[0].row;
        
        var stateName = data.getValue(selectionIdx, 0);
        var value = data.getValue(selectionIdx, 1);
        var st = data.getValue(selectionIdx, 2);
	
     
       
            window.open('http://195.130.109.197:8080/jspui/simple-search?location=%2F&query=' + st+'&rpp=10&sort_by=score&order=desc');
      
    });
    map.draw(data, options);
  };
  </script>	
		

<%
    Community[] communities = (Community[]) request.getAttribute("communities");

    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    String topNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-top.html"));
    String sideNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-side.html"));

    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        feedData = "ALL:" + ConfigurationManager.getProperty("webui.feed.formats");
    }
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    RecentSubmissions submissions = (RecentSubmissions) request.getAttribute("recent.submissions");
%>
<div class="home">

 



<dspace:layout locbar="nolink" titlekey="jsp.home.title" feedData="<%= feedData %>">

	


<div class="row">
	<%@ include file="discovery/static-tagcloud-facet.jsp" %>
</div>
	
</div>
<h2 class="section-header">Search By Country</h2>
    <div id="chart_div"></div>
<div class="home jumbotron">
     
	</div>
</dspace:layout>
</div>
