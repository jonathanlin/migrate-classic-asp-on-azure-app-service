# migrate-classic-asp-on-azure-app-service

Migrating Active Server Pages applications to Azure App Services

ref: https://techcommunity.microsoft.com/t5/azure-migration-and/migrating-active-server-pages-applications-to-azure-app-services/ba-p/3273816

# What I hope you will get out of this blog

Active Server Pages AKA “Classic ASP” was a popular web framework in the late 1990s. There are still many of these running today. If you have such applications and need to migrate these off their existing infrastructure to Azure – then this blog is for you.

This blog presents a step-by-step guide to migrating such applications onto Azure using platform (PaaS) services. This will allow you to take such an application, package it as a container and deploy to Azure, using the simplest approach – targeting Azure App Services.

# So, what is Classic ASP?

Active Server Pages [https://en.wikipedia.org/wiki/Active_Server_Pages](https://en.wikipedia.org/wiki/Active_Server_Pages) was Microsoft’s first framework for building server-side web applications and was released late 1996.

The programming model was quite simple and allowed code to be written in-line in an HTML page, but this would be executed on the web server to generate HTML. A small example is below:

Its final version was late 2000. It has since been replaced by several versions of ASP.Net, but there are still many web sites still running on this technology. To distinguish it from ASP.Net, Active Server Pages is now often referred to as “Classic ASP”.

The site “BuiltWith” tracks usage of web site frameworks – see [https://trends.builtwith.com/framework/Classic-ASP](https://trends.builtwith.com/framework/Classic-ASP) . There are still over 1 million sites with some form of Classic ASP, over 44,000 of which are British web sites.

# Why does this present a challenge?

Many migrations to Azure were initially done as “lift and shift”, where virtual machines are built in Azure to then host applications – very much in the model of on-premise workloads. Increasingly, organisations are seeing the benefits of lower cost and maintenance of platform services, where virtual machines are not the focus. Active Server Pages does not run natively on an Azure platform service in any useful way.

Azure App Services can run a basic ASP page, but then can’t load any other components, so can’t be directly used as a target for real ASP applications.

So, a slightly different approach needs to be taken. This blog describes in detail the approach of building the container version of an ASP application that accesses a database via ODBC – which is the most common form of useful business application.

# Let’s get going

All the code for this blog can be found at [https://github.com/jometzg/classicaspdocker](https://github.com/jometzg/classicaspdocker).

The application is a simple single-page ASP application that shows a page which displays a set of rows from an Azure SQL database.  See below:

# Classic ASP Docker

This is an updated version of thisrepo [https://github.com/ImranMA/CodeSamples/tree/master/aspClassic-Docker](https://github.com/ImranMA/CodeSamples/tree/master/aspClassic-Docker). To demonstrate how a classic ASP application can be containerised and then deployed to a web app for containers (with a Windows service plan):

## Changes

1. Dockerfile has a fixed download reference
2. Added some Classic ASP code to enumerate environment variables to see how these may be injected by Azure Web Apps for Containers.
3. Built some SQL code that accesses data in an Azure SQL database.

## Dockerfile

```bash
# escape=` 
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019 
SHELL ["powershell", "-command"]

ENV APPSETTING_DSN='parameterise this' 

RUN Install-WindowsFeature Web-ASP; `  
 Install-WindowsFeature Web-CGI; `  
 Install-WindowsFeature Web-ISAPI-Ext; `  
 Install-WindowsFeature Web-ISAPI-Filter; `  
 Install-WindowsFeature Web-Includes; `  
 Install-WindowsFeature Web-HTTP-Errors; `  
 Install-WindowsFeature Web-Common-HTTP; `  
 Install-WindowsFeature Web-Performance; `  
 Install-WindowsFeature WAS; `  
 Import-module IISAdministration; 

RUN md c:/msi; 

RUN Invoke-WebRequest 'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi' -OutFile c:/msi/urlrewrite2.msi; `    Start-Process 'c:/msi/urlrewrite2.msi' '/qn' -PassThru | Wait-Process; 

RUN Invoke-WebRequest 'https://download.microsoft.com/download/1/E/7/1E7B1181-3974-4B29-9A47-CC857B271AA2/English/X64/msodbcsql.msi' -OutFile c:/msi/msodbcsql.msi; 

RUN ["cmd", "/S", "/C", "c:\\windows\\syswow64\\msiexec", "/i", "c:\\msi\\msodbcsql.msi", "IACCEPTMSODBCSQLLICENSETERMS=YES", "ADDLOCAL=ALL", "/qn"]; EXPOSE 80 

RUN Remove-Website -Name 'Default Web Site'; `  
 md c:\mywebsite; `  
 New-IISSite -Name "mywebsite" `            
  -PhysicalPath 'c:\mywebsite' `            
  -BindingInformation "*:80:"; 

RUN & c:\windows\system32\inetsrv\appcmd.exe `  
 unlock config `  
 /section:system.webServer/asp 

RUN & c:\windows\system32\inetsrv\appcmd.exe `  
 unlock config `  
 /section:system.webServer/handlers 

RUN & c:\windows\system32\inetsrv\appcmd.exe `  
 unlock config `  
 /section:system.webServer/modules                          

RUN Add-OdbcDsn -Name "SampleDSN" `            
 -DriverName "\"ODBC Driver 13 For SQL Server\"" `            
 -DsnType "System" `             
 -SetPropertyValue @("\"Server=servername.database.windows.net\"", "\"Trusted_Connection=No\"");  

ADD . c:\mywebsite# escape=` 
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019 
SHELL ["powershell", "-command"]

ENV APPSETTING_DSN='parameterise this' 

RUN Install-WindowsFeature Web-ASP; `  
 Install-WindowsFeature Web-CGI; `  
 Install-WindowsFeature Web-ISAPI-Ext; `  
 Install-WindowsFeature Web-ISAPI-Filter; `  
 Install-WindowsFeature Web-Includes; `  
 Install-WindowsFeature Web-HTTP-Errors; `  
 Install-WindowsFeature Web-Common-HTTP; `  
 Install-WindowsFeature Web-Performance; `  
 Install-WindowsFeature WAS; `  
 Import-module IISAdministration; 

RUN md c:/msi; 

RUN Invoke-WebRequest 'https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi' -OutFile c:/msi/urlrewrite2.msi; `    Start-Process 'c:/msi/urlrewrite2.msi' '/qn' -PassThru | Wait-Process; 

RUN Invoke-WebRequest 'https://download.microsoft.com/download/1/E/7/1E7B1181-3974-4B29-9A47-CC857B271AA2/English/X64/msodbcsql.msi' -OutFile c:/msi/msodbcsql.msi; 

RUN ["cmd", "/S", "/C", "c:\\windows\\syswow64\\msiexec", "/i", "c:\\msi\\msodbcsql.msi", "IACCEPTMSODBCSQLLICENSETERMS=YES", "ADDLOCAL=ALL", "/qn"]; EXPOSE 80 

RUN Remove-Website -Name 'Default Web Site'; `  
 md c:\mywebsite; `  
 New-IISSite -Name "mywebsite" `            
  -PhysicalPath 'c:\mywebsite' `            
  -BindingInformation "*:80:"; 

RUN & c:\windows\system32\inetsrv\appcmd.exe `  
 unlock config `  
 /section:system.webServer/asp 

RUN & c:\windows\system32\inetsrv\appcmd.exe `  
 unlock config `  
 /section:system.webServer/handlers 

RUN & c:\windows\system32\inetsrv\appcmd.exe `  
 unlock config `  
 /section:system.webServer/modules                          

RUN Add-OdbcDsn -Name "SampleDSN" `            
 -DriverName "\"ODBC Driver 13 For SQL Server\"" `            
 -DsnType "System" `             
 -SetPropertyValue @("\"Server=servername.database.windows.net\"", "\"Trusted_Connection=No\"");  

ADD . c:\mywebsite
```

Note that it does appear that you do not need to declare the *ENV* in the Dockerfile as would be the case for Linux containers. But it’s probably best to declare this in case this changes for Windows containers in Web App for Containers.

## Environment variables

Following the article here [https://docs.microsoft.com/en-us/azure/app-service/configure-custom-container?pivots=container-windo...](https://docs.microsoft.com/en-us/azure/app-service/configure-custom-container?pivots=container-windows#configure-environment-variables) some code was added to the asp page to enumerate the environment variables:

```bash
<p class="w3-opacity">
<i>      
  <%   Set objWSH =  CreateObject("WScript.Shell")      
       Set objSystemVariables = objWSH.Environment("SYSTEM")      
       For Each strItem In objSystemVariables          
         response.write("<p>" & strItem & "</p>")      
       Next      
  %>      
<p class="w3-opacity"><i>USER</i></p>      
  <%   Set objSystemVariables = objWSH.Environment("USER")      
       For Each strItem In objSystemVariables          
         response.write("<p>" & strItem & "</p>")      
       Next      
  %>
</i>
</p>
```

In the web app configuration a custom application setting was added:

![thumbnail image 1 of blog post titled

    Migrating Active Server Pages applications to Azure App Services

](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/360592iBE4DE987FF8CF4A3/image-size/medium?v=v2&px=400)

When the web page is displayed, you can see this has been picked up.

![thumbnail image 2 of blog post titled

    Migrating Active Server Pages applications to Azure App Services

](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/360593i9C4FE770B96A705D/image-size/medium?v=v2&px=400)

As can be seen, the value *APPSETTING_DATABASE_CONNECTION_STRING=this_is_the_connection_string* gets correctly injected into the container. This will allow connection strings and other settings to be injected into the application.

## Getting a specific environment variable

The above code iterates through the set of environment variables. If there’s a need to get a specific environment variable, the code will look like:

```bash
Set objWSH =  CreateObject("WScript.Shell")conn.open(objWSH.ExpandEnvironmentStrings("%APPSETTING_DSN%"))
```

In the above a web application setting *DSN* is being accessed as *APPSETTING_DSN* and used (in this case) as a connection string to a database connection.

## Accessing an Azure SQL Database

It's often the case that an application needs to access a SQL database. This section covers how to setup the database driver so that ADODB code can use an Azure SQL database.

Firstly, the driver needs to be installed in the container. There are several ways to do this, but the following creates a system DSN that the application can use. I followed some advice from here [https://dotnet-cookbook.cfapps.io/kubernetes/asp-with-odbc/](https://dotnet-cookbook.cfapps.io/kubernetes/asp-with-odbc/)

```bash
RUN Add-OdbcDsn -Name "SampleDSN" `              
  -DriverName "\"ODBC Driver 13 For SQL Server\"" `              
  -DsnType "System" `               
  -SetPropertyValue @("\"Server=yourservername.database.windows.net\"", "\"Trusted_Connection=No\"");
```

This creates a DSN named "SampleDSN".

In the ASP code on the page, this DSN is then used to access the database:

```bash
Dim objConn    
Set objConn = Server.CreateObject("ADODB.Connection")    
Set objWSH =  CreateObject("WScript.Shell")      objConn.open(objWSH.ExpandEnvironmentStrings("%APPSETTING_DSN%"))    
Set objCmd = Server.CreateObject("ADODB.Command")    
objCmd.CommandText = "SELECT * FROM dbo.person"    
objCmd.ActiveConnection = objConn
     
Set objRS = objCmd.Execute     

Do While Not objRS.EOF      
  %><%= objRS("FirstName") %><br><%      
  objRS.MoveNext()    
Loop
```

In the above, I had a sample table "person" in the database with a few rows of data. Note we have injected the connection string in the web app settings - as described previously.

![thumbnail image 3 of blog post titled

    Migrating Active Server Pages applications to Azure App Services

](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/360594i0E1375B135B3ACE9/image-size/medium?v=v2&px=400)

## Building the app

In my case I’m using following names , please change according to your requirements Registry Name = [classicasp.azurecr.io/aspclassic:latest] Image Name = [aspclassic]

Go to the src folder and build the image . [aspclassic] is the name of container, you can change accordingly…

```bash
docker build -t aspclassic -f dockerfile .
```

run the image locally…

```bash
docker run -d -p 8086:80 --name aspclassicapp aspclassic
```

…if you need to 'inject' environment variables into a docker run, here's how:

```applescript
docker run -d -p 8086:80 --env APPSETTING_DSN=the-complete-connection-string  --name aspclassicapp aspclassic
```

It should be noted that quoting the connection string may not be necessary, if there are no spaces. Use of single quotes **'** may cause the quotes to be injected too - making the connection string invalid.

Steps to push the image to Azure Following command will log you into portal:

```bash
az login
```

Login to Azure Container Registry:

```applescript
az acr login --name [Registry Name Here]
```

Tag the image with following command:

```applescript
docker tag aspclassic classicasp.azurecr.io/aspclassic:latestdocker push classicasp.azurecr.io/aspclassic:latest
```

Then deploy a Web App for Containers, pointing to the container images you just uploaded!

## Other samples

Here is a repo [https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/master/windows-container-samples](https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/master/windows-container-samples) with a large number of sample Dockerfiles which may be used as a starting point for containerising Windows-based workloads.

## CI/CD Approach

This approach of:

1. Building a container image
2. Pushing the container image to a container registry
3. Updating the web application with the new container image

is not confined to ASP applications alone and is the standard approach for building any containerised application.

There are many tools for this. At Microsoft, these are primarily GitHub Actions and Azure DevOps pipelines. The simplest approach for both of these is to have two actions/pipelines – one for building and pushing the container image to (in our case) Azure Container Registry. The second to update the web application with that image.

These could be combined into one – only if you need to build and deploy at one go. For production, it’s advised to keep these separate to keep production. A sample GitHub action is shown below:

name: Build and Deploy Windows Container App to Azure App Service

```bash
# Trigger the build on commits into the master branch
on:
  push:
    branches:
      - master

# Starts jobs and sets the type of runner (Windows) they will run on
jobs:
  build-and-deploy-to-azure:
    runs-on: windows-lates
    steps:
    # Checks out repository so your workflow can access it
    - uses: actions/checkout@v1

    # Authenticate a Service Principal to deploy to your Web App (not used for the moment)
    - name: Azure Service Principal Authentication
      uses: azure/login@v1
      with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

    # Use docker login to log into ACR
    - name: Docker login to ACR
      uses: azure/docker-login@v1
      with:
       # comment out the login-server parameter if using docker hub
        login-server: ${{ secrets.CONTAINER_REGISTRY_NAME }}
        username: ${{ secrets.CONTAINER_REGISTRY_USERNAME }}
        password: ${{ secrets.CONTAINER_REGISTRY_PASSWORD }}

    # Build and push your image to Azure Container Registry
    - name: Build and Push container to ACR
      run: |
        docker build --file=./Dockerfile -t ${{ secrets.CONTAINER_REGISTRY_NAME }}/${{ secrets.IMAGE_NAME }}:${{ github.sha }} .
        docker push ${{ secrets.CONTAINER_REGISTRY_NAME }}/${{ secrets.IMAGE_NAME }}:${{ github.sha }} 
   
    # Need to set this in the app if a private repo (which ACR is)
    - name: Set Web App ACR authentication
      uses: Azure/appservice-settings@v1
      with:
       app-name: ${{ secrets.APP_NAME }}
       app-settings-json: |
         [
             {
                 "name": "DOCKER_REGISTRY_SERVER_PASSWORD",
                 "value": "${{ secrets.CONTAINER_REGISTRY_PASSWORD }}",
                 "slotSetting": false
             },
             {
                 "name": "DOCKER_REGISTRY_SERVER_URL",
                 "value": "https://${{ secrets.CONTAINER_REGISTRY_NAME }}",
                 "slotSetting": false
             },
             {
                 "name": "DOCKER_REGISTRY_SERVER_USERNAME",
                 "value": "${{ secrets.CONTAINER_REGISTRY_USERNAME  }}",
                 "slotSetting": false
             }
         ]    

     # Deploy your container to App Service (web app for containers)
    - name: Deploy Container to Azure App Service
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ secrets.APP_NAME }}
        images: ${{ secrets.CONTAINER_REGISTRY_NAME }}/${{ secrets.IMAGE_NAME }}:${{ github.sha }}
```

## Dealing with files

There are some cases where an application not only deals with data stored in an SQL database, but also must work with files. For example, an application that needs to upload a new user’s photograph.

Files represent a challenge for container-based deployment of an application, as a container is meant to be ephemeral. That is, it the file system of the container, by default, will be lost if the container needs to restart.

The application code could be amended, but the goal is to make the least changes to the application possible. It could even be the case hat there is no simple way for the ASP code to access the likes of Azure storage accounts.

A simpler approach is to use a feature of app services where an Azure File Share can be mapped to a path inside the container. This means that any existing code may work without change.

In an app service, this can be configured under Configuration/Path Mappings:

![thumbnail image 4 of blog post titled

    Migrating Active Server Pages applications to Azure App Services

](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/360597i73B543431C13400C/image-size/medium?v=v2&px=400)

In the above, the storage account “jjimages” with a file share of “images” is mapped into the container under the path “/images”. See [https://docs.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage?pivots=contain...](https://docs.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage?pivots=container-windows&tabs=portal#link-storage-to-your-app) for more details.

# Other Thoughts

## Container image size

ASP applications necessarily use Windows rather than Linux containers. These need to be built on a Windows machine – both in development and in build agent/runner. To get all  the right drivers and services and to be able to run these images on app services, these need to be from a base image of Windows Server 2019. This means that the images are over 5 G Bytes in size.

App Services requires that Windows containers run under a plan of type “Premium V3 P1V3”. It has been my experience that only 4 or so applications can run under this size of service plan.

It should also be noted that the start time for these containers is slower than that of Linux containers as there’s extra time needed to pull a large container image from the container registry than for a Linux image.

## Variables and Secrets

Docker has a standard mechanism for injecting environment variables into a starting container. Likewise App Services has a configuration settings capability which may be used to “inject” variables. Some minor code changes may need to be made to accommodate the injection of these values into the container, such as connection strings. For Windows containers, the App Service runtime prefixes these with “APPSETTING_”.

It's also recommended to push secrets into key vault and then to use the App Services managed identity to allow access to the key vault. This is the same for all other app service secrets and is not specific to ASP or Windows containers [Key Vault reference syntax](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references#reference-syntax)

# Conclusion

ASP applications can be packaged very quickly using a relatively fixed Dockerfile – that can be used without modification for several ASP applications. Absolutely minimal code changes need be made to the web application, and these are just to get secrets from the docker environment variables.

The build process is very similar to that for any Docker-based container application and deployment to App Services is also very simple – if a little slower than a normal Linux or other App Service deployment.

This approach facilitates the easy migration of classic ASP applications to Azure App Services. If you have a classic ASP application, give it a go!
