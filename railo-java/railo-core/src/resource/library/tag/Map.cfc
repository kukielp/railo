<cfcomponent name="Map" extends="mapping-tag.railo.core.ajax.AjaxBase">

	<cfset variables.instance._SUPPORTED_MAP_TYPES  = 'map,satellite,hybrid,terrain' />
	<cfset variables.instance._SUPPORTED_TYPES_CONTROL  = 'none,basic,advanced' />
	<cfset variables.instance._SUPPORTED_ZOOM_CONTROL  = 'none,small,large,large3d,small3d' />
	<cfset variables.instance.ajaxBinder = createObject('component','mapping-tag.railo.core.ajax.AjaxBinder').init() />
	<cfset variables.children = [] />
	
	<!--- Meta data --->
	<cfset this.metadata.attributetype="fixed">
    <cfset this.metadata.attributes={
		name:				{required:false,type:"string",default:"_cfmap_#randRange(1,9999999)#"},
		onLoad : 			{required:false,type:"string",default:""},
		onNotFound : 		{required:false,type:"string",default:""},
		onError :		 	{required:false,type:"string",default:""},
		centeraddress : 	{required:false,type:"string",default:""},
		centerlatitude : 	{required:false,type:"string",default:""},
		centerlongitude : 	{required:false,type:"string",default:""},
		height : 			{required:false,type:"numeric",default:400},
		width : 			{required:false,type:"numeric",default:400},
		zoomlevel :   		{required:false,type:"numeric",default:3},
		overview  :         {required:false,type:"boolean",default:false},
		showscale  :        {required:false,type:"boolean",default:false},	
		type :				{required:false,type:"string",default:"map"},
		showcentermarker :  {required:false,type:"boolean",default:true},
		markerwindowcontent:{required:false,type:"string",default:""},
		tip :				{required:false,type:"string",default:""},
		typecontrol : 		{required:false,type:"string",default:"basic"},
		zoomcontrol : 		{required:false,type:"string",default:"small"},
		continuouszoom :    {required:false,type:"boolean",default:true},
		doubleclickzoom :	{required:false,type:"boolean",default:true},
		markercolor : 	    {required:false,type:"string",default:''},
		markericon : 	    {required:false,type:"string",default:''}	
	}>
     
    <cffunction name="init" output="no" returntype="void"
      hint="invoked after tag is constructed">
    	<cfargument name="hasEndTag" type="boolean" required="yes">
      	<cfargument name="parent" type="component" required="no" hint="the parent cfc custom tag, if there is one">

      	<cfset var js = "" />
		<cfset var str = {} />
		<cfset var mappings = getPageContext().getApplicationContext().getMappings() />
				
		<cfset variables.hasEndTag = arguments.hasEndTag />
		<cfset super.init() />

		<cfsavecontent variable="js">
			<cfoutput><script type="text/javascript">
				Railo.Ajax.importTag('CFMAP',null,'google','#variables.instance.RAILOJSSRC#');
				</script>
				</cfoutput>
		</cfsavecontent>

		<cfset writeHeader(js,'_cf_map_import') /> 

  	</cffunction> 
    
    <cffunction name="onStartTag" output="yes" returntype="boolean">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">				

		<cfset variables.attributes = arguments.attributes />
		
		<!--- checks --->		
		<cfif attributes.centeraddress eq "" and (attributes.centerlatitude eq "" or attributes.centerlongitude eq "")>
			<cfthrow message="Attributes [centeraddress] or  [centerlatitude and centerlongitude] are required.">
		</cfif>

		<cfif not listFindNoCase(variables.instance._SUPPORTED_TYPES_CONTROL,attributes.typecontrol)>
			<cfthrow message="Attributes [typecontrol] supported values are [#variables.instance._SUPPORTED_TYPES_CONTROL#].">
		</cfif>

		<cfif not listFindNoCase(variables.instance._SUPPORTED_MAP_TYPES,attributes.type)>
			<cfthrow message="Attributes [type] supported values are [#variables.instance._SUPPORTED_MAP_TYPES#].">
		</cfif>

		<cfif not listFindNoCase(variables.instance._SUPPORTED_ZOOM_CONTROL,attributes.zoomcontrol)>
			<cfthrow message="Attributes [zoomcontrol] supported values are [#variables.instance._SUPPORTED_ZOOM_CONTROL#].">
		</cfif>
		
		<cfif len(attributes.markercolor) and len(attributes.markercolor) neq 6>
			<cfthrow message="Attribute [markercolor] must be in hexadecimal format es : FF0000.">
		</cfif>
		
		<cfoutput><div id="#attributes.name#" style="height:#attributes.height#px;width:#attributes.width#px"> </div></cfoutput>
		
		<cfif not variables.hasEndTag>
 			
		</cfif>

	    <cfreturn variables.hasEndTag />   
	</cffunction>

    <cffunction name="onEndTag" output="yes" returntype="boolean">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">				
  		<cfargument name="generatedContent" type="string">
		
		<cfset doMap(argumentCollection=arguments)/>

		<cfreturn false/>	
	</cffunction>
	
    <!---  children   --->
	<cffunction name="getChildren" access="public" output="false" returntype="array">
		<cfreturn variables.children/>
	</cffunction>
	
	<!---	addChild	--->
    <cffunction name="addChild" output="false" access="public" returntype="void">
    	<cfargument name="child" required="true" type="mapitem" />
		<cfset children = getchildren() />
		<cfset children.add(arguments.child) />
    </cffunction>

	<!---   attributes   --->
	<cffunction name="getAtttributes" access="public" output="false" returntype="struct">
		<cfreturn variables.attributes/>
	</cffunction>

    <cffunction name="getAttribute" output="false" access="public" returntype="any">
		<cfargument name="key" required="true" type="String" />
    	<cfreturn variables.attributes[key] />
    </cffunction>

	<!---doMap--->		   
    <cffunction name="doMap" output="no" returntype="void">
   		<cfargument name="attributes" type="struct">
   		<cfargument name="caller" type="struct">
		
		<cfset var js = "" />
		<cfset var rand = "_Railo_Map_#randRange(1,99999999)#" />	
		
		<cfset var options = duplicate(attributes) />
		<cfset var children = getChildren() />
		
		<cfset structDelete(options,'name') />
					
		<cfsavecontent variable="js"><cfoutput>
		<script type="text/javascript">
		#rand#_on_Load = function(){
			Railo.Map.init('#attributes.name#',#serializeJson(options)#);
			<cfloop array="#children#" index="child">Railo.Map.addMarker('#attributes.name#',#serializeJson(child.getAtttributes())#);</cfloop>
		}		
		Railo.Events.subscribe(#rand#_on_Load,'onLoad');	
		</script>		
		</cfoutput></cfsavecontent>

		<cfset writeHeader(js,'#rand#') /> 
			
	</cffunction>
		
</cfcomponent>