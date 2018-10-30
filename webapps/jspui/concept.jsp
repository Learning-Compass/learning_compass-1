
<!DOCTYPE html>
<meta charset="utf-8">
<h2 class="section-header">Job Pathways</h2> 
<div id="chart1"> </div>
<style>

footer.navbar.navbar-inverse.navbar-bottom {
    display: none;
}

.nav.navbar-nav.navbar-right {
    display: none;
}
</style>
<style>

#graph {
	font-family: "Helvetica Neue", sans-serif;
}
 
.node rect {
  cursor: move;
  fill-opacity: .9;
  shape-rendering: crispEdges;
}
 
.node text {
  pointer-events: none;
  text-shadow: 0 0px 0 #fff;
	font-size: 9px;
	font-family: "Helvetica Neue", sans-serif;
}
 
.link {
  fill: none;
  stroke: #000;
  stroke-opacity: .2;
}
 
.link:hover {
  stroke-opacity: .5;
}
</style>
<body>
 

 
<script src="http://d3js.org/d3.v3.js"></script>
<script src="d3/sankey/sankey.js"></script>
		<script>
			
var units = "Path";
 
var margin = {top: 1, right: 1, bottom: 1, left: 1},
    width = 1000 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;
 
var formatNumber = d3.format(",.0f"),    // zero decimal places
    format = function(d) { return formatNumber(d) + " " + units; },
    color = d3.scale.category20();
 
// append the svg canvas to the page		
var svg = d3.select("#chart1").html("").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", 
          "translate(" + margin.left + "," + margin.top + ")");
 
// Set the sankey diagram properties
var sankey = d3.sankey()
    .nodeWidth(10)
    .nodePadding(50)
    .size([width, height]);
 
var path = sankey.link();
 
// load the data with d3.csv instead of d3.json
d3.csv("d3/sankey/Software_Designer.csv", function(error, data) {
 		//set up graph in same style as original example but empty
  		graph = {"nodes" : [], "links" : []};
  
                data.forEach(function (d, i) {
                    graph.nodes.push({ "name": d.source });
                    graph.nodes.push({ "name": d.target });

										graph.links.push({ "source": d.source, 
																			 "target": d.target, 
																			 "value": d.value });
								})	

	
                //thanks Mike Bostock https://groups.google.com/d/msg/d3-js/pl297cFtIQk/Eso4q_eBu1IJ
                //this handy little function returns only the distinct / unique nodes
                graph.nodes = d3.keys(d3.nest()
                         .key(function (d) { return d.name; })
                         .map(graph.nodes));
												 
								//it appears d3 with force layout wants a numeric source and target
                //so loop through each link replacing the text with its index from node
								graph.links.forEach(function (d, i) {
										graph.links[i].source = graph.nodes.indexOf(graph.links[i].source);
                    graph.links[i].target = graph.nodes.indexOf(graph.links[i].target);
								});

								//now loop through each nodes to make nodes an array of objects rather than an array of strings
                graph.nodes.forEach(function (d, i) {
                    graph.nodes[i] = { "name": d };
                });
	
  sankey
      .nodes(graph.nodes)
      .links(graph.links)
      .layout(32);
 
// add in the links
  var link = svg.append("g").selectAll(".link")
      .data(graph.links)
    .enter().append("path")
      .attr("class", "link")
      .attr("d", path)
      .style("stroke-width", function(d) { return Math.max(1, d.dy); })
      .sort(function(a, b) { return b.dy - a.dy; });
 
// add the link titles
  link.append("title")
        .text(function(d, i) {
      	return "link #" + (parseInt(i)+2) + "\n" +
					d.source.name + " → " + d.target.name + "\n" + 
					format(d.value); });
 

// add in the nodes
  var node = svg.append("g").selectAll(".node")
      .data(graph.nodes)
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { 
		  return "translate(" + d.x + "," + d.y + ")"; })
    .call(d3.behavior.drag()
      .origin(function(d) { return d; })
      .on("dragstart", function() { 
		  		this.parentNode.appendChild(this);
				})
      .on("drag", dragmove))
			.on("mouseover", fade(0.2))
			.on("mouseout", fade(1));
 
// add the rectangles for the nodes
  node.append("rect")
      .attr("height", function(d) { return d.dy; })
      .attr("width", sankey.nodeWidth())
      .style("fill", function(d) { 
		  return d.color = color(d.name.replace(/ .*/, "")); })
      .style("stroke", function(d) { 
		  return d3.rgb(d.color).darker(2); })
    .append("title")
      .text(function(d, i) { 
		  return "node #" + i + "\n" + d.name + "\n" + format(d.value); 
			});
 
// add in the title for the nodes
  node.append("svg:a").attr("xlink:href", function(d){ return "http://195.130.109.197:8080/jspui/simple-search?query=" + d.name })
  .append("text")
  
      .attr("x", -6)
      .attr("y", function(d) { return d.dy / 2; })
      .attr("dy", ".35em")
      .attr("text-anchor", "end")
      .attr("transform", null)
      .text(function(d) { return d.name; })
    .filter(function(d) { return d.x < width / 2; })
      .attr("x", 6 + sankey.nodeWidth())
      .attr("text-anchor", "start");






// the function for moving the nodes
  function dragmove(d) {
    d3.select(this).attr("transform", 
        "translate(" + (
        	   d.x = Math.max(0, Math.min(width - d.dx, d3.event.x))
        	) + "," + (
                   d.y = Math.max(0, Math.min(height - d.dy, d3.event.y))
            ) + ")");
    sankey.relayout();
    link.attr("d", path);
  };
	
// Returns an event handler for fading a given chord group.
// http://bl.ocks.org/mbostock/4062006
function fade(opacity) {
  return function(g, i) {
    var elements = svg.selectAll(".node");
    elements = elements.filter(function(d) { return d.name != graph.nodes[i].name });
    elements.transition()
        .style("opacity", opacity);

		svg.selectAll(".link")
        .filter(function(d) { return d.source.name != graph.nodes[i].name && d.target.name != graph.nodes[i].name })
      .transition()
        .style("opacity", opacity);
  };
}	
	
	
	
});
			
		</script>
		
		<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>

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

	

 <h2 class="section-header">Search for Job Profiles By Competence</h2>
	


 

<%@ include file="d3/concept/concept.html" %>  
</dspace:layout>
</div>
 
</body>

</html>