<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Renders a whole HTML page for displaying item metadata.  Simply includes
  - the relevant item display component in a standard HTML page.
  -
  - Attributes:
  -    display.all - Boolean - if true, display full metadata record
  -    item        - the Item to display
  -    collections - Array of Collections this item appears in.  This must be
  -                  passed in for two reasons: 1) item.getCollections() could
  -                  fail, and we're already committed to JSP display, and
  -                  2) the item might be in the process of being submitted and
  -                  a mapping between the item and collection might not
  -                  appear yet.  If this is omitted, the item display won't
  -                  display any collections.
  -    admin_button - Boolean, show admin 'edit' button
--%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.handle.HandleManager" %>
<%@ page import="org.dspace.license.CreativeCommons" %>
<%@page import="javax.servlet.jsp.jstl.fmt.LocaleSupport"%>
<%@page import="org.dspace.versioning.Version"%>
<%@page import="org.dspace.core.Context"%>
<%@page import="org.dspace.app.webui.util.VersionUtil"%>
<%@page import="org.dspace.app.webui.util.UIUtil"%>
<%@page import="org.dspace.authorize.AuthorizeManager"%>
<%@page import="java.util.List"%>
<%@page import="org.dspace.core.Constants"%>
<%@page import="org.dspace.eperson.EPerson"%>
<%@page import="org.dspace.versioning.VersionHistory"%>

<%@page import="java.sql.*"%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Vector"%>
<%@page import="java.util.TreeMap"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.HashMap"%>


<script type='text/javascript' src="../../static/js/jquery/jquery-1.10.2.min.js"></script>
<script type='text/javascript' src='../../static/js/jquery/jquery-ui-1.10.3.custom.min.js'></script>
<script type='text/javascript' src='../../static/js/bootstrap/bootstrap.min.js'></script>
<script type='text/javascript' src='../../static/js/holder.js'></script>
<script type="text/javascript" src="../../utils.js"></script>
<script type="text/javascript" src="../../static/js/choice-support.js"></script>


<%

    String path_server = request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/handle/";

    // Attributes
    Boolean displayAllBoolean = (Boolean) request.getAttribute("display.all");
    boolean displayAll = (displayAllBoolean != null && displayAllBoolean.booleanValue());
    Boolean suggest = (Boolean) request.getAttribute("suggest.enable");
    boolean suggestLink = (suggest == null ? false : suggest.booleanValue());
    Item item = (Item) request.getAttribute("item");
	
    Collection[] collections = (Collection[]) request.getAttribute("collections");
    Boolean admin_b = (Boolean) request.getAttribute("admin_button");
    boolean admin_button = (admin_b == null ? false : admin_b.booleanValue());

    // get the workspace id if one has been passed
    Integer workspace_id = (Integer) request.getAttribute("workspace_id");

    // get the handle if the item has one yet
    String handle = item.getHandle();

    // CC URL & RDF
    String cc_url = CreativeCommons.getLicenseURL(item);
    String cc_rdf = CreativeCommons.getLicenseRDF(item);

    // Full title needs to be put into a string to use as tag argument
    String title = "";
    if (handle == null) {
        title = "Workspace Item";
    } else {
        Metadatum[] titleValue = item.getDC("title", null, Item.ANY);
        if (titleValue.length != 0) {
            title = titleValue[0].value;
        } else {

            title = "Item " + handle;
        }
    }

    Boolean versioningEnabledBool = (Boolean) request.getAttribute("versioning.enabled");
    boolean versioningEnabled = (versioningEnabledBool != null && versioningEnabledBool.booleanValue());
    Boolean hasVersionButtonBool = (Boolean) request.getAttribute("versioning.hasversionbutton");
    Boolean hasVersionHistoryBool = (Boolean) request.getAttribute("versioning.hasversionhistory");
    boolean hasVersionButton = (hasVersionButtonBool != null && hasVersionButtonBool.booleanValue());
    boolean hasVersionHistory = (hasVersionHistoryBool != null && hasVersionHistoryBool.booleanValue());

    Boolean newversionavailableBool = (Boolean) request.getAttribute("versioning.newversionavailable");
    boolean newVersionAvailable = (newversionavailableBool != null && newversionavailableBool.booleanValue());
    Boolean showVersionWorkflowAvailableBool = (Boolean) request.getAttribute("versioning.showversionwfavailable");
    boolean showVersionWorkflowAvailable = (showVersionWorkflowAvailableBool != null && showVersionWorkflowAvailableBool.booleanValue());

    String latestVersionHandle = (String) request.getAttribute("versioning.latestversionhandle");
    String latestVersionURL = (String) request.getAttribute("versioning.latestversionurl");

    VersionHistory history = (VersionHistory) request.getAttribute("versioning.history");
    List<Version> historyVersions = (List<Version>) request.getAttribute("versioning.historyversions");
%>


<%
    String url = "jdbc:postgresql://localhost:5432/dspace";
    Connection con;
    ResultSet rst;

//out.println(sqlstr);
    HashMap<Integer, String> hm_title = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_description = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_date = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_creator = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_publisher = new HashMap<Integer, String>();

    HashMap<Integer, String> hm_rights = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_language = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_credit = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_level = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_assessment = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_cost = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_duration = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_engagement = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_languageOfInstruction = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_location = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_objective = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_places = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_start = new HashMap<Integer, String>();

    HashMap<Integer, String> hm_subject = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_qualification = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_prerequisite = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_competence = new HashMap<Integer, String>();

    HashMap<Integer, String> hm_identifier = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_url = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_relation = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_hasPart = new HashMap<Integer, String>();
    HashMap<Integer, String> hm_specifies = new HashMap<Integer, String>();

    HashMap<String, String> hm_images = new HashMap<String, String>();
    HashMap<String, String> hm_specf = new HashMap<String, String>();
    HashMap<String, String> hm_handle_item = new HashMap<String, String>();
    HashMap<String, String> hm_inst_specf = new HashMap<String, String>();

    HashMap<String, String> handle_credit = new HashMap<String, String>();
    HashMap<String, String> handle_qualf = new HashMap<String, String>();

    HashMap<String, String> handle_level = new HashMap<String, String>();
    HashMap<String, String> handle_ass = new HashMap<String, String>();
	
	HashMap<Integer, Integer> itemtoimage = new HashMap<Integer, Integer>();

    String cm_id = "";
    String cl_id = "";

    con = DriverManager.getConnection(url, "dspace", "dspace");

    Statement st = con.createStatement();

    //get community_id, collocte_id for specifies
    String com_coll = "select distinct c2i.collection_id,cmc.community_id from collection2item c2i ,metadatavalue a,collection2item b, handle h , "
            + "community2collection cmc where "
            + "c2i.collection_id= b.collection_id and "
            + "a.resource_id=cmc.collection_id and "
            + "a.resource_id=b.collection_id and "
            + "a.metadata_field_id=64 and "
            + "a.resource_type_id=3 and "
            + "b.item_id=h.resource_id and "
            + "(h.handle ='" + handle + "')	";

    rst = st.executeQuery(com_coll);

    while (rst.next()) {
        cl_id = rst.getString(1);
        cm_id = rst.getString(2);
    }

    rst.close();

    String specf = "select a.text_value ,h.handle  from metadatavalue a ,handle h "
            + "where a.metadata_field_id in (142) and h.resource_id=a.resource_id and a.resource_id in (select distinct c2i.item_id from collection2item c2i ,metadatavalue a,community2collection cmc where "
            + "cmc.community_id=" + cm_id + " and "
            + "c2i.collection_id!=" + cl_id + " and "
            + "cmc.collection_id=c2i.collection_id and "
            + "c2i.item_id=a.resource_id and a.metadata_field_id in (142))";

    rst = st.executeQuery(specf);
    String tmp;

    while (rst.next()) {
        tmp = rst.getString(2);
        hm_specf.put(tmp, rst.getString(1));

    }

    rst.close();

    //image/cc-somerights
    String sqlimg = "select b.handle,b2b.bitstream_id from item2bundle ib,handle b,bundle2bitstream b2b "
            + "where  ib.item_id=b.resource_id and b.handle='" + handle + "'and ib.bundle_id=b2b.bundle_id";

    rst = st.executeQuery(sqlimg);

    while (rst.next()) {
        hm_images.put(rst.getString(1), rst.getString(2));
    }

    rst.close();

    //hm handle -> title	
    String sqlhandle = "select b.handle,a.text_value from metadatavalue a,handle b "
            + "where a.metadata_field_id in (64) and b.resource_id=a.resource_id ";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_handle_item.put(rst.getString(1), rst.getString(2));

    }

    //title	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (64) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_title.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_description	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (26) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_description.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_date	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (10) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_date.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_creator	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (9) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_creator.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_publisher	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (39) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_publisher.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

////////////////////////Educational/////////////////////////////////				
//hm_rights	
    sqlhandle = "select string_agg(a.text_value,' ,'),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (53) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_rights.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_language	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (38) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_language.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_credit	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (146) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_credit.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_level	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (148) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_level.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_assessment	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (145) and b.resource_id=a.resource_id and b.handle='" + handle + "' group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_assessment.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_cost	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (133) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_cost.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_duration	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (134) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_duration.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_engagement	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (135) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_engagement.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_languageOfInstruction	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (137) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_languageOfInstruction.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_location	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (138) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_location.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_objective	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (139) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_objective.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_places	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (140) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_places.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_start	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (143) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_start.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

    ///////////////////////////////////Category///////////////////////////////////////////////////////////						
//hm_subject	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (57) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_subject.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_qualification	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (151) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_qualification.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_prerequisite	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (150) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_prerequisite.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_competence	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (153) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_competence.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

    ////////////////////////////////////////////Technical//////////////////////////////////////////////////					
//hm_identifier	
    sqlhandle = "select string_agg(a.text_value,' , '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (17) and b.resource_id=a.resource_id and b.handle='" + handle + "'  group by(a.resource_id)";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_identifier.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_url	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (152) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_url.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_relation	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (40) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_relation.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_hasPart	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (136) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_hasPart.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

//hm_specifies	
    sqlhandle = "select a.text_value,a.resource_id,a.metadata_field_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (142) and b.resource_id=a.resource_id and b.handle='" + handle + "'";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_specifies.put(rst.getInt(2), rst.getString(1));
    }

    rst.close();

    //////////////////////////////////////////////////////////////////////////////////////////////					
    //hm_instance or specification
    sqlhandle = "select h.handle,a.text_value from metadatavalue a,collection2item b, handle h "
            + "where a.resource_id=b.collection_id and a.metadata_field_id=64 and a.resource_type_id=3 "
            + "and b.item_id=h.resource_id";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        hm_inst_specf.put(rst.getString(1), rst.getString(2));
    }

    rst.close();

    sqlhandle = "select a.text_value,a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (146) and b.resource_id=a.resource_id and b.handle= "
            + "(select substring(a.text_value from 0 for position('#'in a.text_value)) from metadatavalue a,handle b "
            + "where a.metadata_field_id in (142) and b.resource_id=a.resource_id and b.handle='" + handle + "') ";

    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        handle_credit.put(handle, rst.getString(1));
    }

    rst.close();

    sqlhandle = "select a.text_value,a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (151) and b.resource_id=a.resource_id and b.handle= "
            + "(select substring(a.text_value from 0 for position('#'in a.text_value)) from metadatavalue a,handle b "
            + "where a.metadata_field_id in (142) and b.resource_id=a.resource_id and b.handle='" + handle + "') ";

    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        handle_qualf.put(handle, rst.getString(1));
    }

    rst.close();

    sqlhandle = "select a.text_value,a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (148) and b.resource_id=a.resource_id and b.handle= "
            + "(select substring(a.text_value from 0 for position('#'in a.text_value)) from metadatavalue a,handle b "
            + "where a.metadata_field_id in (142) and b.resource_id=a.resource_id and b.handle='" + handle + "') ";

    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        handle_level.put(handle, rst.getString(1));
    }

    rst.close();

    sqlhandle = "select string_agg(a.text_value,'  ,  '),a.resource_id from metadatavalue a,handle b "
            + "where a.metadata_field_id in (145) and b.resource_id=a.resource_id and b.handle= "
            + "(select substring(a.text_value from 0 for position('#'in a.text_value)) from metadatavalue a,handle b "
            + "where a.metadata_field_id in (142) and b.resource_id=a.resource_id and b.handle='" + handle + "') group by(a.resource_id) ";
//out.print(sqlhandle+"//tsolak");

    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        handle_ass.put(handle, rst.getString(1));

    }

    rst.close();

	
	
	
	
//itemtoimage	
    sqlhandle = "select i.item_id,bu.bitstream_id from item2bundle i,item2bundle ib,bundle2bitstream bu,bitstream bi "+
"where i.item_id=ib.item_id and ib.bundle_id=bu.bundle_id and bu.bitstream_id=bi.bitstream_id";
    rst = st.executeQuery(sqlhandle);

    while (rst.next()) {
        itemtoimage.put(rst.getInt(1), rst.getInt(2));
    }

    rst.close();
	
	
	
    st.close();
    con.close();

    List<Integer> keyList = new ArrayList<Integer>(hm_title.keySet());
    List<String> specifyitemList = new ArrayList<String>(hm_specf.keySet());


%>


<%    String s;
    String hd = "";
    String hd1 = "";
    String nm = "";
    String nm1 = "";
    String anm = "";
    String anm1 = "";
    String cnm = "";
    String cnm1 = "";
    String hm_key1 = "";

    int hm_key = 0;
    for (Integer temp : keyList) {
        hd = (String) hm_title.get(temp);
        hm_key = temp;

    }

    //String hd_image = handle.substring(handle.indexOf("/"), handle.length());

    String url_iamge = "/jspui/image/no_thumbnail.jpg";

    if (hm_images.get(handle) != null) {
        url_iamge = "/jspui/retrieve/" + itemtoimage.get(item.getID());
    }


%>








<%@page import="org.dspace.app.webui.servlet.MyDSpaceServlet"%>



<dspace:layout title="<%= title%>">
    <%
        if (handle != null) {
			
			%>
			<div class="itemPage">
    <div class="itemDisplay">
        <div class='title-container'>
            <div class="metadataFieldValue" id="metadatafv_title"><%= hm_title.get(hm_key)%></div>
            <div class="title-separator"></div>

        </div>
        <div class="general-container row">
            <div class="thumbnail-container col-md-3">
                <img class="thumbnail" src="<%= url_iamge%>" alt="no thumbnail">
                <div class="handle"><%= handle%></div>

            </div>
			
            <div class="rest-of-general-container  col-md-9">

                <div class="row  description-row">
                    <div class="col-md-12">
                        <div class="metadataFieldLabels" id="metadatafl_description">Description</div>
                        <div class="metadataFieldValue" id="metadatafv_description"><%= hm_description.get(hm_key)%></div>
                    </div>
					
									 <%if (hm_inst_specf.get(handle).equals("Job_Profiles")) {%>
						 <div class="col-md-12">
                  <div class="metadataFieldLabels" id="metadatafl_creator">Qualifications</div>
				  <div class="metadataFieldValue" id="metadatafv_creator"><%= hm_objective.get(hm_key).replaceAll("Outcomes::", "").replaceAll(",", "<br>")%></div>
				  </div>
					<% }%>

                </div>
                <div class="row rest-row">
				 <%if (!hm_inst_specf.get(handle).equals("Specifications")&&!hm_inst_specf.get(handle).equals("Job_Profiles")) {%>
                    <div class="col-md-4"><div class="metadataFieldLabels" id="metadatafl_learningOpportunity">Start Date</div><div class="metadataFieldValue" id="metadatafv_learningOpportunity"><%= hm_date.get(hm_key)%></div></div>
				<% }%>
				 <%if (!hm_inst_specf.get(handle).equals("Job_Profiles")) {%>
                    <div class="col-md-4"><div class="metadataFieldLabels" id="metadatafl_creator">Creator</div><div class="metadataFieldValue" id="metadatafv_creator"><%= hm_creator.get(hm_key)%></div></div>
					<% }%>
                    <div class="col-md-4"><div class="metadataFieldLabels" id="metadatafl_publisher">Publisher</div><div class="metadataFieldValue" id="metadatafv_publisher"><%= hm_publisher.get(hm_key)%></div>
                    </div>
					
					 </div>
					 
		
               
				
				                        
						  <% if (hm_specifies.get(hm_key) != null) {
							  
							  out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_specifies\">Specifies</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_specifies\">");
							  
							 out.print("<a href=\"http://" + path_server + hm_specifies.get(hm_key) + "\">" + hm_handle_item.get(hm_specifies.get(hm_key).substring(0, hm_specifies.get(hm_key).indexOf("#"))) + "</a>");
							 out.print("</div>");
						  }

                            
                 


	
							  if (!specifyitemList.isEmpty()) {


 out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_specified\">Specified Instances</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_specified\">");

                                    for (String temp1 : specifyitemList) {
                                        hd1 = (String) hm_specf.get(temp1);
                                        hm_key1 = temp1;

                                        String trim_value = hm_specf.get(hm_key1).substring(0, hm_specf.get(hm_key1).indexOf("#"));
										
                                        if (trim_value.equals(handle)) {

                                            out.print("<a href=\"http://" + path_server + temp1 + "\">" + (hm_handle_item.get(hm_key1)) + "</a><br>");
                                        }

                                    }

out.print("</div>");

							  }
							  
							  

%>

                <div class="well">Please use this identifier to cite or link to this item:
                    <code><%= handle%></code></div>

            </div>
	 <%if (!hm_inst_specf.get(handle).equals("Job_Profiles")) {%>
            <div class="show-info-bt-container">
                <div class="show-info-bt">
                    <span id="show-more" class="info-bt">MORE INFO</span>
                    <span id="show-less" class="info-bt hide">LESS INFO</span>
                    <span id="show-info-bt-icon" class="glyphicon glyphicon-chevron-right"></span>
                </div>

            </div>
	 <%}%>
            <div id="more-info-container" class="more-info" style="display:none;">
                <div class="col-md-6">
                    <div class="educational-section info-section">

                        <div class="educational section-title">
                            <h3>Educational</h3>
                        </div>
                        <div class="info-container">
                           
						   <% 
						   
						   		   		////////////////////
if (hm_rights.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_rights\">Rights</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_rights\">");
										out.print( hm_rights.get(hm_key));
							 out.print("</div>");
							}
					
						   		////////////////////
if (hm_cost.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_cost\">Cost</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_cost\">");
										out.print( hm_cost.get(hm_key));
							 out.print("</div>");
							}
					
						   
						   		////////////////////
if (hm_engagement.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_attendance\">Attendance Mode</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_attendance\">");
										out.print( hm_engagement.get(hm_key));
							 out.print("</div>");
							}
						   
						   
						   
						   
						   
						   
						   if (hm_inst_specf.get(handle).equals("Instances") && handle_credit.get(handle) != null) {
								
								
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_cost\">Credits</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_cost\">");
										out.print(handle_credit.get(handle));
							 out.print("</div>");
								
								} else if (hm_credit.get(hm_key) != null) {
									
									
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_cost\">Credits</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_cost\">");
										out.print(hm_credit.get(hm_key));
							 out.print("</div>");
									
								}



                           if (hm_inst_specf.get(handle).equals("Instances") && handle_ass.get(handle) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_assessment\">Assessment</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_assessment\">");
										out.print(handle_ass.get(handle));
							 out.print("</div>");
								
								
								
								
								} else if (hm_assessment.get(hm_key) != null) {
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_assessment\">Assessment</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_assessment\">");
										out.print(hm_assessment.get(hm_key));
							 out.print("</div>");
									
								}

							
							
							/////////////////////
							if (hm_inst_specf.get(handle).equals("Instances") && handle_level.get(handle) != null) {
								
							out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_assessment\">Level</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_assessment\">");
										out.print(handle_level.get(handle));
							 out.print("</div>");	
								
								
                            } else if (hm_assessment.get(hm_key) != null) {
								
							out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_assessment\">Level</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_assessment\">");
										out.print(hm_level.get(hm_key));
							 out.print("</div>");	
							}



                         

								////////////////////
if (hm_duration.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_duration\">Duration</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_duration\">");
										out.print( hm_duration.get(hm_key));
							 out.print("</div>");
							}
							
							
			////////////////////
if (hm_location.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_language\">Language Of Instruction</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_language\">");
										out.print( hm_location.get(hm_key));
							 out.print("</div>");
							}
							
							
							////////////////////
if (hm_location.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_location\">Location</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_location\">");
										out.print( hm_location.get(hm_key));
							 out.print("</div>");
							}

							
							////////////////////
if (hm_objective.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_outcomes\">Outcomes</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_outcomes\">");
										out.print( hm_objective.get(hm_key));
							 out.print("</div>");
							}





/////////////
							if (hm_places.get(hm_key) != null) {
								
									out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_places\">Places</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_places\">");
										out.print( hm_places.get(hm_key));
							 out.print("</div>");
							}
							
								
								%>
								
								
								
								
								
								
								
								
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="category-section info-section">
                        <div class="category section-title">
                            <h3>Category</h3>
                        </div>
                        <div class="info-container">
                            


                            <% 
							
								 if (hm_subject.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_rights\">Subject</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_rights\">");
										out.print(hm_subject.get(hm_key).replaceAll("::", "->"));
							 out.print("</div>");
							}
							
							
							////////////////////////////
							if (hm_inst_specf.get(handle).equals("Instances") && handle_qualf.get(handle) != null) {
								
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_qualification\">Qualification</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_qualification\">");
								
								out.print( handle_qualf.get(handle));
								out.print("</div>");
                            
                            } else if (hm_qualification.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_qualification\">Qualification</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_qualification\">");
								out.print(hm_qualification.get(hm_key));
								out.print("</div>");
							}
							
							//////////////
							 if (hm_prerequisite.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_prequisites\">Prerequisite Learning Opportunities</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_prequisites\">");
										out.print(hm_prerequisite.get(hm_key).replaceAll("::", "->"));
							 out.print("</div>");
							}
							//////////////
								 if (hm_competence.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_competence\">Prerequisite Competences</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_competence\">");
										out.print(hm_competence.get(hm_key).replaceAll("::", "->"));
							 out.print("</div>");
							}
								%>	
								
                        </div>
                    </div>
                </div>
               
			   <div class="col-md-6">
                    <div class="technical-section info-section">
                        <div class="technical section-title">
                            <h3>Technical</h3>
                        </div>
                        <div class="info-container">

                    <h3>Technical</h3>

                       
							
							                      
						  <% if (hm_url.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_url\">URI</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_url\">");
										out.print("<a href='" + hm_url.get(hm_key) + "'>" + hm_url.get(hm_key) + "</a>");
							 out.print("</div>");
							}
								%>	
								
								
						
						  <% if (hm_relation.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_relation\">Relation</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_relation\">");
								out.print(hm_relation.get(hm_key));
							 out.print("</div>");
							}
								%>	
						
						
                            <% if (hm_hasPart.get(hm_key) != null) {
								out.println("<div class=\"metadataFieldLabels\" id=\"metadatafl_hasPart\">HasPart</div>");
							  	out.println("<div class=\"metadataFieldValue\" id=\"metadatafv_hasPart\">");
								out.print("<a href='http://" + path_server + hm_hasPart.get(hm_key) + "'>" + hm_handle_item.get(hm_hasPart.get(hm_key).substring(0, hm_hasPart.get(hm_key).indexOf("#"))) + "</a>");
							 out.print("</div>");
							}
								%>	
							
							
							
							
  
<%							  

   out.print("<div class=\"metadataFieldLabels\" id=\"metadatafl_appearsin\">Appears in Collections</div><div class=\"metadataFieldValue\" id=\"metadatafv_appearsin\">"+hm_inst_specf.get(handle));
						 
						 if (hm_inst_specf.get(handle).equals("Specifications")) {
							 out.print("<div class=\"type-Specifications-details\"></div>");
							 
                             } else if (hm_inst_specf.get(handle).equals("Instances")) {
								  out.print("<div class=\"type-instance-details\"></div>"); } 
								  out.print("</div>");

								  
								  
								  
								  
								  


						
                       out.print("</div>");
                 
            
			

               		
         


%>
</div>
</div>
</div>
</div></div>
</div>
			
			
			

    <%
    if (admin_button) // admin edit button
    {%>
    <dspace:sidebar>
        <div class="panel panel-warning">
            <div class="panel-heading"><fmt:message key="jsp.admintools"/></div>
            <div class="panel-body">
                <form method="get" action="<%= request.getContextPath()%>/tools/edit-item">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>" />
                    <%--<input type="submit" name="submit" value="Edit...">--%>
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.edit.button"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath()%>/mydspace">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>" />
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_EXPORT_ARCHIVE%>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.mydspace.request.export.item"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath()%>/mydspace">
                    <input type="hidden" name="item_id" value="<%= item.getID()%>" />
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.REQUEST_MIGRATE_ARCHIVE%>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.mydspace.request.export.migrateitem"/>" />
                </form>
                <form method="post" action="<%= request.getContextPath()%>/dspace-admin/metadataexport">
                    <input type="hidden" name="handle" value="<%= item.getHandle()%>" />
                    <input class="btn btn-default col-md-12" type="submit" name="submit" value="<fmt:message key="jsp.general.metadataexport.button"/>" />
                </form>
               
            </div>
        </div>
    </dspace:sidebar>
    <%      } %>

    <%
        }

       
    %>

    
    
  

  
    </dspace:layout>

<script type="text/javascript">
    $('.show-info-bt').click(function () {
        $('#show-more').toggleClass('hide');
        $('#show-less').toggleClass('hide');
        $('#show-info-bt-icon').toggleClass('glyphicon-chevron-down');
        $('#show-info-bt-icon').toggleClass('glyphicon-chevron-right');
        $('#more-info-container').slideToggle('slow');
    });
</script>
