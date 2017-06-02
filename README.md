# JDV Open Data

## Overview
This simple project uses JBoss Data Virtualization to expose data in Open Data format.

The data was gathered in [Portal da Transparência](http://www.portaldatransparencia.gov.br/downloads/mensal.asp?c=FavorecidosGastosDiretos#meses01), a Brazilian government website that provides open data.

The datasource consists in:
* One Postgresql database table
	* [schema.sql](./database/postgresql/schema.sql) - Natureza Jurídica - Legal type of a company in Brazil
![Overview](/files/png/104.png?raw=true "Overview")
* Two CSV files
	* [CNAE.csv](./files/FavorecidosGastosDiretos/CNAE.csv) - Classificação Nacional de Atividades Econômicas - Economic activities of Brazilian companies
![Overview](/files/png/100.png?raw=true "Overview")
	* [CNPJ.csv](./files/FavorecidosGastosDiretos/CNPJ.csv) - Cadastro Nacional da Pessoa Jurídica - List of Brazilian companies
* One SOAP Webservice
![Overview](/files/png/101.png?raw=true "Overview")
	* [Country Info Service](http://www.oorsprong.org/websamples.countryinfo/CountryInfoService.wso?wsdl)
![Overview](/files/png/102.png?raw=true "Overview")
* Canonical model
![Overview](/files/png/103.png?raw=true "Overview")

There are two types of installations. See bellow the instructions for each one:
* [xPaaS Deployment (Openshift 3.5)](#xpaas-deployment-openshift-35)
* [Standalone Deployment (EAP)](#standalone-deployment-eap)


# xPaaS Deployment (Openshift 3.5)

## Overview
Used folders/files:
* [configuration/standalone-openshift](./configuration/standalone-openshift)
	* Final EAP configuration file. Defines:
		* Datasource: java:/NaturezaJuridica
		* Resource Adapter: CNPJSource
		* Resource Adapter: CNAESource
		* Resource Adapter: CountrySource
	* There are alternative ways to configure the datasources and resource adapters:
		* CLI script
			* Not tested
		* Environment variables defined in: [database/datasources.env](./database/datasources.env) 
			* Did not work in my tests
* [files/FavorecidosGastosDiretos/CNAE.csv](./files/FavorecidosGastosDiretos/CNAE.csv)
* [files/FavorecidosGastosDiretos/CNPJ.csv](./files/FavorecidosGastosDiretos/CNPJ.csv)
* [database/datasources.env](./database/datasources.env)
	* Used for security constraints and to define environment variables.
	* As is, it is not useful, but does not work without it. Maybe if the security constraint was dropped. Test needed to validate.
* [database/postgresql/schema.sql](./database/postgresql/schema.sql)
* [deployments/OpenData.vdb](./deployments/OpenData.vdb)
	* Will be copied to EAP deployment folder.
* [deployments/OpenData.vdb.dodeploy](./deployments/OpenData.vdb.dodeploy)
	* Will be copied to EAP deployment folder and will trigger the deployment of the VDB file.

## Project setup
Login in oc cli:
```
oc login openshift.example.com:8443 -u demo -p r3dh4t1!
```

Create a new Openshift project via web browser. Example: jdv-opendata
![Project setup](/files/png/01.png?raw=true "Project setup")


After, you need to setup the security constraints:
```
oc create serviceaccount datavirt-service-account
oc policy add-role-to-user view system:serviceaccount:jdv-opendata:datavirt-service-account
oc secrets new datavirt-app-config datasources.env
oc secrets link datavirt-service-account datavirt-app-config
```

## Postgresql 9.5 Image setup
* Add to Project
	* ![Postgresql 9.5 Image setup](/files/png/02.png?raw=true "Postgresql 9.5 Image setup")
* Browse Catalog
	* Search for: postgresql-persistent 
	* ![Postgresql 9.5 Image setup](/files/png/03.png?raw=true "Postgresql 9.5 Image setup")
	* Click in Select
* Image setup
	* Database Service Name: postgresql
	* PostgreSQL Connection Username: redhat
	* PostgreSQL Connection Password: redhat@123
	* PostgreSQL Database Name: redhat
	* Click in Create
	* ![Postgresql 9.5 Image setup](/files/png/04.png?raw=true "Postgresql 9.5 Image setup")

* Continue to overview
	* ![Postgresql 9.5 Image setup](/files/png/05.png?raw=true "Postgresql 9.5 Image setup")

* Create Route
	* ![Postgresql 9.5 Image setup](/files/png/06.png?raw=true "Postgresql 9.5 Image setup")
	* Click in Create

## Database setup
To create and populate the database table, just run the script [schema.sql](./database/postgresql/schema.sql) using the connection created above.

If you are using Openshift via a Virtual Machine, you need to create a port-forward in order to access your service:
```
oc get pods
oc port-forward <POSTGRESQL-POD-NAME> 15432:5432 &
```
![Database setup](/files/png/07.png?raw=true "Database setup")


## JBoss Data Virtualization 6.3 Image setup
* Add to Project
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/08.png?raw=true "JBoss Data Virtualization 6.3 Image setup")
* Browse Catalog
	* Search for: datavirt63-basic-s2i 
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/09.png?raw=true "JBoss Data Virtualization 6.3 Image setup")
	* Click in Select
* Image setup
	* Application Name: datavirt-app
	* Git Repository URL: https://github.com/kerdlix/jdv-opendata
	* Context Directory: /
	* Teiid Username: teiidUser
	* Teiid User Password: redhat@123
	* ModeShape Username: modeShape
	* ModeShape User Password: redhat@123
	* Click in Create
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/10.png?raw=true "JBoss Data Virtualization 6.3 Image setup")
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/11.png?raw=true "JBoss Data Virtualization 6.3 Image setup")
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/12.png?raw=true "JBoss Data Virtualization 6.3 Image setup")
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/13.png?raw=true "JBoss Data Virtualization 6.3 Image setup")
* Continue to overview
	* ![JBoss Data Virtualization 6.3 Image setup](/files/png/14.png?raw=true "JBoss Data Virtualization 6.3 Image setup")

## Database connection
If you are using Openshift via a Virtual Machine, you need to create a port-forward in order to access your service:
```
oc get pods
oc port-forward <JDV-OPENDATA-POD-NAME> 41000:31000 &
```
![Database connection](/files/png/15.png?raw=true "Database connection")


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

## Internal DNS setup
If you are using Openshift via a Virtual Machine, you need to create an entry in your /etc/hosts (assuming your Openshift IP is 192.168.56.100):
```
192.168.56.100 datavirt-app-jdv-opendata.cloudapps.example.com
```

## OData test
You can test your VDB via OData using the following URLs (login with teiidUser/redhat@123):
* [URL Sample #01](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/NaturezaJuridicaModel.NaturezaJuridica?$format=JSON)
* [URL Sample #02](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/NaturezaJuridicaModel.NaturezaJuridica(1023)?$format=JSON)
* [URL Sample #03](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/CNAEModel.CNAE?$format=JSON)
* [URL Sample #04](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/CNAEModel.CNAE(codigoSecao='A',codigoSubclasse=111301)?$format=JSON)
* [URL Sample #05](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/CNPJModel.CNPJ?$format=JSON)
* [URL Sample #06](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/CNPJModel.CNPJ('100160000102')?$format=JSON)
* [URL Sample #07](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/ModeloCanonico.FavorecidosGastosDiretos?$format=JSON)
* [URL Sample #08](http://datavirt-app-jdv-opendata.cloudapps.example.com/odata/OpenData.1/ModeloCanonico.FavorecidosGastosDiretos('119123000146')?$format=JSON)


## Useful links
* [https://github.com/cvanball/jdv-ose-demo](https://github.com/cvanball/jdv-ose-demo)
* [https://github.com/jboss-openshift/openshift-quickstarts/tree/master/datavirt/dynamicvdb-datafederation](https://github.com/jboss-openshift/openshift-quickstarts/tree/master/datavirt/dynamicvdb-datafederation)


# Standalone Deployment (EAP)

## Overview
Used folders:
* src
* files
* database

## Source Code
The project source code is in [src](./src) directory and consists in a JBoss Developer Studio 8.1.0 GA Teiid Model Project. It has:
* Sources
	* For CSV files, Postgresql database and WebService
* Views
	* Models for the sources, with joins and materialized view tables
* VDB
	* It generates the VDB file [OpenData.vdb](./src/OpenData.vdb).


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
You can test your VDB via OData using the following URLs (login with teiidUser/redhat@123):
* [URL Sample #01](http://localhost:8080/odata/OpenData.1/NaturezaJuridicaModel.NaturezaJuridica?$format=JSON)
* [URL Sample #02](http://localhost:8080/odata/OpenData.1/NaturezaJuridicaModel.NaturezaJuridica(1023)?$format=JSON)
* [URL Sample #03](http://localhost:8080/odata/OpenData.1/CNAEModel.CNAE?$format=JSON)
* [URL Sample #04](http://localhost:8080/odata/OpenData.1/CNAEModel.CNAE(codigoSecao='A',codigoSubclasse=111301)?$format=JSON)
* [URL Sample #05](http://localhost:8080/odata/OpenData.1/CNPJModel.CNPJ?$format=JSON)
* [URL Sample #06](http://localhost:8080/odata/OpenData.1/CNPJModel.CNPJ('100160000102')?$format=JSON)
* [URL Sample #07](http://localhost:8080/odata/OpenData.1/ModeloCanonico.FavorecidosGastosDiretos?$format=JSON)
* [URL Sample #08](http://localhost:8080/odata/OpenData.1/ModeloCanonico.FavorecidosGastosDiretos('119123000146')?$format=JSON)

