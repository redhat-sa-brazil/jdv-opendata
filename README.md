# JDV Open Data

## Overview
This simple project uses JBoss Data Virtualization to expose data in Open Data format.

The data was gathered in [Portal da Transparência](http://www.portaldatransparencia.gov.br/downloads/mensal.asp?c=FavorecidosGastosDiretos#meses01), a Brazilian government website that provides open data.

The datasource consists in:
* One Postgresql database table
	* Natureza Jurídica - Legal type of a company in Brazil
		* [schema.sql](./database/postgresql/schema.sql)
* Two CSV files
	* Classificação Nacional de Atividades Econômicas - Economic activities of Brazilian companies
		* [CNAE.csv](./files/FavorecidosGastosDiretos/CNAE.csv)
	* Cadastro Nacional da Pessoa Jurídica - List of Brazilian companies
		* [CNPJ.csv](./files/FavorecidosGastosDiretos/CNPJ.csv)
* One SOAP Webservice
	* Country Info Service
		* [WSDL](http://www.oorsprong.org/websamples.countryinfo/CountryInfoService.wso?wsdl)

## Source Code
The project source code is in [src](./src) directory and consists in a JBoss Developer Studio 8.1.0 GA Teiid Model Project. It has:
* Sources
	* For CSV files, Postgresql database and WebService
* Views
	* Models for the sources, with joins and materialized view tables
* VDB
	* It generates the VDB file [OpenData.vdb](./src/OpenData.vdb).


# Standalone Deployment (EAP)

## Database setup
To create and populate the database table, just run the script [schema.sql](./database/postgresql/schema.sql)

## EAP setup
It is necessary to have the following resources created in EAP:
* Datasource
	* jndi-name="java:/NaturezaJuridica"
		* Example (change the URL/username/password as needed):
		    ```
		        <datasource jndi-name="java:/NaturezaJuridica" pool-name="NaturezaJuridica" enabled="true">
		            <connection-url>jdbc:postgresql://postgresql:5432/redhat</connection-url>
		            <driver>postgresql</driver>
		            <security>
		                <user-name>redhat</user-name>
		                <password>redhat@123</password>
		            </security>
		        </datasource>
		    ```
* Resource Adapter
	* resource-adapter id="CNPJSource"
		* Example (change the Path/file name as needed):
		    ```
		        <resource-adapter id="CNPJSource">
		            <module slot="main" id="org.jboss.teiid.resource-adapter.file"/>
		            <transaction-support>NoTransaction</transaction-support>
		            <connection-definitions>
		                <connection-definition class-name="org.teiid.resource.adapter.file.FileManagedConnectionFactory" jndi-name="java:/CNPJSource" enabled="true" pool-name="CNPJSource">
		                    <config-property name="ParentDirectory">
		                        /home/jboss/source/files/FavorecidosGastosDiretos
		                    </config-property>
		                </connection-definition>
		            </connection-definitions>
		        </resource-adapter>
		    ```
	* resource-adapter id="CNAESource"
		* Example (change the Path/file name as needed):
		    ```
		        <resource-adapter id="CNAESource">
		            <module slot="main" id="org.jboss.teiid.resource-adapter.file"/>
		            <transaction-support>NoTransaction</transaction-support>
		            <connection-definitions>
		                <connection-definition class-name="org.teiid.resource.adapter.file.FileManagedConnectionFactory" jndi-name="java:/CNAESource" enabled="true" pool-name="CNAESource">
		                    <config-property name="ParentDirectory">
		                        /home/jboss/source/files/FavorecidosGastosDiretos
		                    </config-property>
		                </connection-definition>
		            </connection-definitions>
		        </resource-adapter>
		    ```
	* resource-adapter id="CountrySource"
		* Example (change the URL name as needed):
		    ```
		        <resource-adapter id="CountrySource">
		            <module slot="main" id="org.jboss.teiid.resource-adapter.webservice"/>
		            <transaction-support>NoTransaction</transaction-support>
		            <connection-definitions>
		                <connection-definition class-name="org.teiid.resource.adapter.ws.WSManagedConnectionFactory" jndi-name="java:/CountrySource" enabled="true" pool-name="CountrySource">
		                    <config-property name="SecurityType">
		                        None
		                    </config-property>
		                    <config-property name="EndPoint">
		                        http://www.oorsprong.org/websamples.countryinfo/CountryInfoService.wso
		                    </config-property>
		                </connection-definition>
		            </connection-definitions>
		        </resource-adapter>
		    ```

## EAP Deployment
Copy the file [OpenData.vdb](./src/OpenData.vdb) to deployment folder of your EAP instance.

## JDBC setup
The VDB will be available at this URL: [jdbc:teiid:OpenData@mm://localhost:31000](jdbc:teiid:OpenData@mm://localhost:31000).

## JDBC test
You can test your VDB using the following SQL statements:
* select * from NaturezaJuridica;
* select * from NaturezaJuridicaCache;
* select * from CNPJ;
* select * from CNPJCache;
* select * from CNAE;
* select * from CNAECache;
* select * from Empresas;
* select * from EmpresasCache;
* select * from FavorecidosGastosDiretos;
* select * from FavorecidosGastosDiretosCache;
* select * from CountryName where sCountryISOCode = 'BR';

## OData test
You can test your VDB via OData using the following URLs:
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/NaturezaJuridicaModel.NaturezaJuridica?$format=JSON](http://localhost:8080/odata/FavorecidosGastosDiretos.1/NaturezaJuridicaModel.NaturezaJuridica?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/NaturezaJuridicaModel.NaturezaJuridica(1023)?$format=JSON](http://localhost:8080/odata/FavorecidosGastosDiretos.1/NaturezaJuridicaModel.NaturezaJuridica(1023)?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNAEModel.CNAE?$format=JSON](http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNAEModel.CNAE?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNAEModel.CNAE(codigoSecao='A',codigoSubclasse=111301)?$format=JSON]([http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNAEModel.CNAE(codigoSecao='A',codigoSubclasse=111301)?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNPJModel.CNPJ?$format=JSON](http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNPJModel.CNPJ?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNPJModel.CNPJ('100160000102')?$format=JSON]([http://localhost:8080/odata/FavorecidosGastosDiretos.1/CNPJModel.CNPJ('100160000102')?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/ModeloCanonico.FavorecidosGastosDiretos?$format=JSON](http://localhost:8080/odata/FavorecidosGastosDiretos.1/ModeloCanonico.FavorecidosGastosDiretos?$format=JSON)
* [http://localhost:8080/odata/FavorecidosGastosDiretos.1/ModeloCanonico.FavorecidosGastosDiretos('119123000146')?$format=JSON](http://localhost:8080/odata/FavorecidosGastosDiretos.1/ModeloCanonico.FavorecidosGastosDiretos('119123000146')?$format=JSON)







http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/NaturezaJuridicaModel.NaturezaJuridicaCache?$format=JSON
http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/NaturezaJuridicaModel.NaturezaJuridicaCache(1023)?$format=JSON

http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/CNAEModel.CNAECache?$format=JSON
http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/CNAEModel.CNAECache(codigoSecao='A',codigoSubclasse=111301)?$format=JSON

http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/CNPJModel.CNPJCache?$format=JSON
http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/CNPJModel.CNPJCache('100160000102')?$format=JSON

http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/ModeloCanonico.FavorecidosGastosDiretosCache?$format=JSON
http://datavirt-app-opendata.cloudapps.example.com/odata/OpenData.1/ModeloCanonico.FavorecidosGastosDiretosCache('119123000146')?$format=JSON










## xPaaS Deployment





Portal da transparência
Projecto eclispe
Xpaas





##Overview

This only differs from the stock Teiid _dynamicvdb-datafederation_ quickstart in the following ways:

* The directory structure has changed.
* The [portfolio-vdb.xml](./app/portfolio-vdb.xml) has been modified to work with h2, Derby, MySQL and PostgreSQL.  The modifications include:
    * adding translator definitions for the above listed database types
    * setting `importer.widenUnsignedTypes=false` to ensure MySQL integer types are consistent with what is expected in the other models.
    * adding a reference to an environment variable, `QS_DB_TYPE`, which is used to specify the translator  used by the _Accounts_ source
* It includes the [hibernate-portfolio-vdb.xml](./app/hibernate-portfolio-vdb.xml) file from the _hibernate-on-top-of-teiid_ quickstart.
* It includes a modified version of the jdg-remote-cache-materialization quickstart, which has been modified as follows:
    * The jar file is output directly into the modules directory hierarchy.
    * The kits folder has been removed.  The modules directory hierarchy is now created by maven automatically.
    * The modules folder is created in the parent directory, so it gets copied automatically as part of the s2i process
    * The jdg-remote-cache-mat-vdb.xml file is copied into the parent directory, so it gets deployed automatically as part of the s2i process.

###Directory Structure

The directory structure is organized as follows:

* [./app/](./app) - everything that needs to be deployed to the server, which includes:
    * `*-vdb.xml` - the VDB files
    * [data/databases/h2/](./app/data/databases/h2) - the h2 database instance
    * [data/databases/derby/](./app/data/databases/derby) - the Derby database instance
    * [data/teiidfiles/data/](./app/data/teiidfiles/data) - the file data for the `market-data` resource
    * [data/teiidfiles/excelFiles/](./app/data/teiidfiles/excelFiles) - the file data for the `excel-file` resource
    * [datagrid-materialization/](./app/datagrid-materialization) - maven project which illustrates how to setup a materialized view using a Red Hat JBoss Data Grid cache as a target datasource.  This project builds a modules folder hierarchy in the parent directory (which is automatically added to JDV during the S2I process) and copies the VDB file into parent (which is also copied into the deployments folder as part of S2I).  This project is based on the jdg-remote-cache-materialization quickstart.
        * [src/main/java/](./app/datagrid-materialization/src/main/java) - the pojo classes defining the data structure for the view
        * [src/main/module/](./app/datagrid-materialization/src/main/module) - the module.xml file for the EAP module containing the pojo jar.  This is referenced by the resource adapter configuration used to connect to the cache.
        * [src/main/vdb/](./app/datagrid-materialization/src/main/vdb) - the VDB file defining the views for the cache and materialization.
* [./derby/](./derby) - Derby specific DDL and instructions
* [./h2/](./h2) - h2 specific DDL and instructions
* [./mysql/](./mysql) - MySQL specific DDL and instructions
* [./postgresql/](./postgresql) - PostgreSQL specific DDL and instructions
* [./datasources.env](./datasources.env) provides configuration information for the datasource and resource adapters required by this quickstart

###Datasource Configuration

The datasources are configured using environment variables, which are defined through the [datasources.env](./datasources.env) file.
* datasources: (`DATASOURCES` variable)
    * `ACCOUNTS_DERBY` is the datasource configuration for use with Derby
    * `ACCOUNTS_H2` is the datasource configuration for use with h2
    * `ACCOUNTS_MYSQL5` is the datasource configuration for use with MySQL
    * `ACCOUNTS_POSTGRESQL` is the datasource configuration for use with PostgreSQL
* resource adapters: (`RESOURCE_ADAPTERS` variable)
    * `MARKETDATA` is the resource adapter configuration for the market data files
    * `EXCEL` is the resource adapter configuration for the Excel files
    * `MAT_CACHE` is the resource adapter configuration for the JDG cache used with materialization.  This is added to the `RESOURCE_ADAPTERS` list if the `jdg-remote-cache-mat-vdb.xml` is deployed on the server.

The `QS_DB_TYPE` variable is used to define which datasource configuration is used and can be one of (all lower case): `derby`, `h2`, `mysql5` or `postgresql`.  By default, this is set to `h2`, but may be changed by editing the deployment configuration for the application.  This must be defined as part of the deployment configuration within OpenShift to have any affect on the VDB.  Setting it in [datasources.env](./datasources.env) will affect the datasource that gets created, but the VDB will use the translator specified by the setting on the deployment configuration.  The [portfolio-vdb.xml](./app/portfolio-vdb.xml) file uses `${env.QS_DB_TYPE:h2}` to select the translator that should be used with the _Accounts_ model, and defaults to `h2`.

The `VDB_DIRS` variable is used to enable the materialization aspect of this quickstart.  If this environment variable is set with a value of ".,datagrid-materialization/src/vdb", the [datagrid-materialization](./app/datagrid-materialization) project will be built and included in the image.

The configuration details are passed to the pod through a secret.

##Deploying the Quickstart

This quickstart can be deployed as follows:

1.  Instantiate one of the following templates:

    * `datavirt63-basic-s2i`
    * `datavirt63-secured-s2i` (includes configuration for https and jdbc (over SNI) routes)

    Specifying parameters as follows:

    * `SOURCE_REPOSITORY_URL`: https://github.com/jboss-openshift/openshift-quickstarts
    * `SOURCE_REPOSITORY_REF`: master
    * `CONTEXT_DIR`: datavirt/dynamicvdb-datafederation/app

    Remember to note the Teiid username and password (both randomly generated), which should be displayed after processing the template.  Optionally, you can specify your own values:

    * `TEIID_USERNAME`: teiidUser
    * `TEIID_PASSWORD`: sup3rSecret!

    > Note: the password must adhere to the password strength rules or deployment will fail.

2.  Create the secret for the datasource configuration.

    ```
    $ oc secrets new datavirt-app-config datasources.env
    ```

3.  Link the secret to the service account used by the application.

    ```
    $ oc secrets link datavirt-service-account datavirt-app-config
    ```

4.  Experiment with other the database types.

    Add `QS_DB_TYPE` to the `datavirt-app` deployment configuration, e.g.:

    ```
    $ oc env dc/datavirt-app QS_DB_TYPE=mysql5
    ```

    Set this to one of the values listed in the _Datasource Configuration_ section.  Follow the type specific instructions for initializing the database (e.g. seeding the data).  After modifying the deployment configuration, the current deployment should be replaced with a new deployment containing your changes.

> Note: Steps two and three are unnecessary if using the [datavirt-app-secret](https://github.com/jboss-openshift/application-templates/blob/master/secrets/datavirt-app-secret.yaml), as `datavirt-app-config` secret is defined and linked to the service account when that file is installed (e.g. `oc create -f application-templates/secrets/datavirt-app-secret.yaml`).

### Using Red Hat JBoss Data Grid for Materialization

As a prerequisite, you will need to create a data grid service in your OpenShift project.  This can
be done by using one of the datagrid65-* templates (e.g. datagrid65-basic).  When processing the template,
ensure the following parameters are set appropriately:

* `DATAVIRT_CACHE_NAMES`=addressbook

The above will configure three caches: addressbook, addressbook_staging and addressbook_alias.

Once the data grid server is up and running, a materialized view based on a JDG cache can be added to the project by specifying the `DATAGRID_MATERIALIZATION` environment variable on the build configuration, e.g.:

    ```
    $ oc env bc/datavirt-app DATAGRID_MATERIALIZATION=true
    ```

This should trigger a new build, followed by a new deployment.  You can access the cache directly using the `PeopleMat.PersonMatCache` view, and you can access the materialized view at `PeopleMat.PersonMatModel`.  For more information, reference the jdg-remote-cache-materialization quickstart for Red Hat JBoss Data Virtualization.
 
